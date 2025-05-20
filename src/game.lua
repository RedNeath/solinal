require 'command_manager'
require 'pile'
require 'spreaded_pile'
require 'family'
require 'card'

Game = {
    settings = nil,
    command_manager = nil,
    stock_pile = nil,
    supply_pile = nil,
    pit = nil,
    board = nil
}

function Game:new(game_settings)
    local g = setmetatable({}, self)
    self.__index = self

    g.settings = game_settings
    g.command_manager = CommandManager:new(game_settings.history_size)
    g.stock_pile = Pile:new()
    g.supply_pile = Pile:new()

    g.pit = {
        Pile:new(),
        Pile:new(),
        Pile:new(),
        Pile:new(),
    }

    g.board = {
        SpreadedPile:new(),
        SpreadedPile:new(),
        SpreadedPile:new(),
        SpreadedPile:new(),
        SpreadedPile:new(),
        SpreadedPile:new(),
        SpreadedPile:new()
    }

    g:initialise()

    return g
end

function Game:initialise()
    -- Let's create the deck and shuffle it first!
    local deck = shuffle_deck(create_deck())

    -- Then let's add cards to each pile
    local pile_index = 1
    local line_index = 1

    while line_index <= #self.board do
        while pile_index <= #self.board do
            local picked_card = table.remove(deck, 1)

            if pile_index == line_index then
                picked_card:flip()
            end

            self.board[pile_index]:push(picked_card)
            pile_index = pile_index + 1
        end

        line_index = line_index + 1
        pile_index = line_index
    end

    -- And finally, let's add the remaining cards to the stock pile.
    self.stock_pile:set_cards(deck)
end

function Game:all_cards_upwards()
    for _,board_pile in pairs(self.board) do
        if not board_pile:all_cards_upwards() then
            return false
        end
    end

    return true
end

function Game:get_lowest_pit_index()
    local lowest_index = 1

    for index, pile in pairs(self.pit) do
        if pile:peek():continuous_value() < self.pit[lowest_index]:peek():continuous_value() then
            lowest_index = index
        end
    end

    return lowest_index
end

function Game:find_cards_in_supply_pile(card_id)
    local result = nil
    local supply_card = self.supply_pile:peek()

    if supply_card and supply_card.id == card_id then
        result = {
            cards = { supply_card },
            place = "SUPPLY"
        }
    end

    return result
end

function Game:find_cards_in_pit_piles(card_id)
    local result = nil

    for pile_index,pile in pairs(self.pit) do
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

function Game:find_cards_in_board_piles(card_id)
    local result = nil

    for pile_index,pile in pairs(self.board) do
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

function Game:find_card_by_id(card_id)
    local result = self:find_cards_in_supply_pile(card_id)
        or self:find_cards_in_pit_piles(card_id)
        or self:find_cards_in_board_piles(card_id)

    return result
end

function Game:find_pile_by_id(pile_id)
    local result = nil
    local pile_initial = string.sub(pile_id, 1, 1)
    local pile_index = tonumber(string.sub(pile_id, 2, 2))

    if pile_id == "SUPPLY" then
        result = { 
            pile = self.supply_pile,
            type = "SUPPLY"
        }

    elseif pile_initial == "P"
            and pile_index
            and pile_index > 0
            and pile_index <= #self.pit
    then
        result = { 
            pile = self.pit[pile_index],
            type = "PIT"
        }

    elseif pile_initial == "B"
            and pile_index
            and pile_index > 0
            and pile_index <= #self.board
    then
        result = {
            pile = self.board[pile_index],
            type = "BOARD"
        }
    end

    return result
end

function Game:render_superior_content()
    -- We need to render elements line by line. Here, the number of lines to
    -- write is fixed, so we could just use a simple for loop, but it's not
    -- going to be the case for the board, so we'll use an iterator instead.
    local stock_pile_it = self.stock_pile:get_iterator()
    local supply_pile_it = self.supply_pile:get_iterator()
    local pit_pile_1_it = self.pit[1]:get_iterator() -- Not a loop to make sure the order remains the same
    local pit_pile_2_it = self.pit[2]:get_iterator()
    local pit_pile_3_it = self.pit[3]:get_iterator()
    local pit_pile_4_it = self.pit[4]:get_iterator()

    local content = ""
    while stock_pile_it:has_next()
        or supply_pile_it:has_next()
        or pit_pile_1_it:has_next()
        or pit_pile_2_it:has_next()
        or pit_pile_3_it:has_next()
        or pit_pile_4_it:has_next()
    do
        content = content .. stock_pile_it:next() .. "  "
            .. supply_pile_it:next()
            .. "             "
            .. pit_pile_1_it:next() .. "  "
            .. pit_pile_2_it:next() .. "  "
            .. pit_pile_3_it:next() .. "  "
            .. pit_pile_4_it:next() .. "\n"
    end

    return content
end

function Game:render_board()
    local pile_1_it = self.board[1]:get_iterator()
    local pile_2_it = self.board[2]:get_iterator()
    local pile_3_it = self.board[3]:get_iterator()
    local pile_4_it = self.board[4]:get_iterator()
    local pile_5_it = self.board[5]:get_iterator()
    local pile_6_it = self.board[6]:get_iterator()
    local pile_7_it = self.board[7]:get_iterator()

    local content = ""
    while pile_1_it:has_next()
        or pile_2_it:has_next()
        or pile_3_it:has_next()
        or pile_4_it:has_next()
        or pile_5_it:has_next()
        or pile_6_it:has_next()
        or pile_7_it:has_next()
    do
        content = content .. pile_1_it:next() .. "  "
            .. pile_2_it:next() .. "  "
            .. pile_3_it:next() .. "  "
            .. pile_4_it:next() .. "  "
            .. pile_5_it:next() .. "  "
            .. pile_6_it:next() .. "  "
            .. pile_7_it:next() .. "\n"
    end

    return content
end

function Game:clear_screen()
    os.execute(self.settings.clear_command)
end

function Game:display(with_question)
    self:clear_screen()

    print("  STOCK      SUPPLY                 P 1        P 2        P 3        P 4")
    print(self:render_superior_content())
    print("   B 1        B 2        B 3        B 4        B 5        B 6        B 7")
    print(self:render_board())
    
    if self:all_cards_upwards() then
        print("🎉 You won this game! You can complete it automatically with the command \"finish\"!")
    end

    if with_question then
        print("What action do you want to perform?")
    end
end


-- UTILITY FUNCTIONS --

function shuffle_deck(cards)
    math.randomseed(os.time())
    local shuffled = {}
    for i, v in ipairs(cards) do
	    local pos = math.random(1, #shuffled+1)
	    table.insert(shuffled, pos, v)
    end

    return shuffled
end

function create_deck()
    local cards = {}

    local family_table = {
        { name = "C", symbol = "♣", colour = "" },
        { name = "S", symbol = "♠", colour = "" },
        { name = "H", symbol = "♥", colour = "\027[31m" },
        { name = "D", symbol = "♦", colour = "\027[31m" },
    }

    for _,f in pairs(family_table) do
        local family_cards = create_family_cards(f.name, f.symbol, f.colour)
        for _,c in pairs(family_cards) do
            table.insert(cards, c)
        end
    end

    return cards
end

function create_family_cards(name, symbol, colour)
    local family = Family:new(name, symbol, colour)

    return {
        Card:new(family, "A", nil),
        Card:new(family, "2", nil),
        Card:new(family, "3", nil),
        Card:new(family, "4", nil),
        Card:new(family, "5", nil),
        Card:new(family, "6", nil),
        Card:new(family, "7", nil),
        Card:new(family, "8", nil),
        Card:new(family, "9", nil),
        Card:new(family, "10", nil),
        Card:new(family, "J", nil),
        Card:new(family, "Q", nil),
        Card:new(family, "K", nil)
    }
end
