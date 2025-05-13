require 'pile'

local card_height = 8
local short_card_height = 2

-- Provides a pile with the right display_height (empty)
SpreadedPile = Pile:new()

function SpreadedPile:compute_display_height()
    if self.count <= 1 then
        self.display_height = card_height
    else
        self.display_height = card_height +
            (self.count - 1) * short_card_height
    end
end

function SpreadedPile:push(card)
    table.insert(self.cards, card)
    self.count = self.count + 1

    self:compute_display_height()
end

function SpreadedPile:set_cards(cards)
    self.cards = cards
    self.count = #self.cards

    self:compute_display_height()
end

function SpreadedPile:pop()
    local card = table.remove(self.cards, self.count)
    self.count = self.count - 1

    self:compute_display_height()

    return card
end

function SpreadedPile:remove_at(index)
    local card = table.remove(self.cards, index)
    self.count = self.count - 1

    self:compute_display_height()

    return card
end

function SpreadedPile:render_line(index)
    if self.count == 0 then
        return EMPTY_PILE[index]
    end

    local is_short = (index <= (self.count - 1) * 2)

    if is_short then
        local card_index = math.ceil(index / 2)
        local card_line = index - (card_index - 1) * 2

        return self.cards[card_index].short_representation[card_line]
    else
        local card_line = index - (self.count - 1) * 2

        return self:peek().representation[card_line]
    end
end

function SpreadedPile:display()
    if self.count == 0 then
        self:display_empty_pile()
        return
    end

    -- Pile not empty
    for k,v in pairs(self.cards) do
        if k == self.count then
            v:display()
        else
            v:display_short()
        end
    end
end

