require 'command'

Moveto = Command:new()

function Moveto:new(game, args)
    local mt = setmetatable({}, self)
    self.__index = self

    mt.name = "moveto"
    mt.game = game

    if not args[1] or not args[2] then
        mt.error = "Missing argument for this command!"
    else
        mt.card = args[1]
        mt.destination = args[2]
    end

    return mt
end

function Moveto:find_cards_in_supply_pile(card_id)
    local result = nil
    local supply_card = self.game.supply_pile:peek()

    if supply_card and supply_card.id == card_id then
        result = {
            cards = { supply_card },
            place = "SUPPLY"
        }
    end

    return result
end

function Moveto:find_cards_in_pit_piles(card_id)
    local result = nil

    for pile_index,pile in pairs(self.game.pit) do
        local pit_card = pile:peek()

        if pit_card and pit_card.id == card_id then
            result = {
                cards = { pit_card },
                place = "P" .. pile_index
            }
            break
        end
    end

    return result
end

function Moveto:find_cards_in_board_piles(card_id)
    local result = nil

    for pile_index,pile in pairs(self.game.board) do
        for _,card in pairs(pile.cards) do
            if result then -- We take the card and the cards on top of it.
                table.insert(result.cards, card)
            elseif not card:is_flipped() and card.id == card_id then
                result = {
                    cards = { card },
                    place = "B" .. pile_index
                }
            end
        end

        if result then
            break -- We found the card(s)
        end
    end

    return result
end

function Moveto:find_card_by_id(card_id)
    local result = self:find_cards_in_supply_pile(card_id)
        or self:find_cards_in_pit_piles(card_id)
        or self:find_cards_in_board_piles(card_id)

    if not result then
        self.error = "No matching card found to move around"
    end

    return result
end

function Moveto:find_pile_by_id(pile_id)
    local result = nil
    local pile_initial = string.sub(pile_id, 1, 1)
    local pile_index = tonumber(string.sub(pile_id, 2, 2))

    if pile_id == "SUPPLY" then
        result = { 
            pile = self.game.supply_pile,
            type = "SUPPLY"
        }

    elseif pile_initial == "P"
            and pile_index
            and pile_index > 0
            and pile_index <= #self.game.pit
    then
        result = { 
            pile = self.game.pit[pile_index],
            type = "PIT"
        }

    elseif pile_initial == "B"
            and pile_index
            and pile_index > 0
            and pile_index <= #self.game.board
    then
        result = {
            pile = self.game.board[pile_index],
            type = "BOARD"
        }
    end

    return result
end

function Moveto:find_destination_from_cards(destination_id)
    local destination_pile = nil
    local destination_cards = self:find_card_by_id(destination_id)

    if destination_cards
            and #destination_cards.cards == 1 
            and destination_cards.place ~= "SUPPLY"
    then
        destination_pile = self:find_pile_by_id(destination_cards.place)
    elseif destination_pile and not self.error then
        self.error = "Move not allowed."
    end

    return destination_pile
end

function Moveto:find_destination(destination_id)
    local destination_pile = self:find_pile_by_id(destination_id)
        or self:find_destination_from_cards(destination_id)

    if not destination_pile and not self.error then
        self.error = "Couldn't find move destination."
    end

    return destination_pile
end

function Moveto:validate_move(cards_to_move, destination_pile)
    local pit_valid = destination_pile.type ~= "PIT" or (
        #cards_to_move.cards == 1
        and (
            (cards_to_move.cards[1]:continuous_value() == 1 and not destination_pile.pile:peek())
            or (
                destination_pile.pile:peek() and destination_pile.pile:peek().family.name == cards_to_move.cards[1].family.name
                and (destination_pile.pile:peek():continuous_value() + 1) == cards_to_move.cards[1]:continuous_value()
            )
        )
    )

    local board_valid = destination_pile.type ~= "BOARD" or (
        (cards_to_move.cards[1]:continuous_value() == 13 and not destination_pile.pile:peek())
        or (
            destination_pile.pile:peek()
            and destination_pile.pile:peek():continuous_value() == (cards_to_move.cards[1]:continuous_value() + 1)
            and destination_pile.pile:peek().family.colour ~= cards_to_move.cards[1].family.colour
            and destination_pile.pile:peek().id ~= self:find_pile_by_id(cards_to_move.place).pile:peek().id
        )
    )

    if not pit_valid or not board_valid then
        self.error = "Move not allowed."
    end
end

function Moveto:execute()
    if self.error then
        print(self.error)
        return
    end

    -- Gathering necessary information
    local cards_to_move = self:find_card_by_id(self.card)

    if self.error then
        print(self.error)
        return
    end
    self.source_pile_id = cards_to_move.place -- Marking this for undo

    local destination_pile = self:find_destination(self.destination)

    if self.error then
        print(self.error)
        return
    end

    -- Calculating whether the move is allowed or not
    self:validate_move(cards_to_move, destination_pile)

    if self.error then
        print(self.error)
        return
    end

    -- And finally performing the move
    local source_pile = self:find_pile_by_id(cards_to_move.place)
    -- os.execute(self.game.settings.audio_command .. self.game.settings.paths.assets.card_move)
    while #cards_to_move.cards > 0 do
        local card = table.remove(cards_to_move.cards, 1)
        source_pile.pile:remove_at(source_pile.pile.count - #cards_to_move.cards)

        destination_pile.pile:push(card)
    end

    if source_pile.pile:peek() and source_pile.pile:peek():is_flipped() then
        -- self.game:display()
        -- os.execute(self.game.settings.audio_command .. self.game.settings.paths.assets.card_flip)
        self.flipped_card_on_top = true
        source_pile.pile:peek():flip()
    end
end

function Moveto:undo()
    if self.error then
        print("Command unsuccessful: " .. self.error .. "\nDidn't undo anything")
        return
    end

    -- If we get there, that means the command was successful, so it can be undone too.
    local cards_to_move = self:find_card_by_id(self.card)
    local destination_pile = self:find_destination(self.destination)
    local source_pile = self:find_pile_by_id(self.source_pile_id)

    if self.flipped_card_on_top then
        source_pile.pile:peek():flip()
    end

    while #cards_to_move.cards > 0 do
        local card = table.remove(cards_to_move.cards, 1)
        destination_pile.pile:remove_at(destination_pile.pile.count - #cards_to_move.cards)

        source_pile.pile:push(card)
    end
end
