require 'pile_iterator'

EMPTY_PILE = {
    "+   -   +",
    "         ",
    "         ",
    "|       |",
    "         ",
    "         ",
    "         ",
    "+   -   +"
}

Pile = {
    cards = {},
    count = 0,
    display_height = 0,
}

function Pile:new()
    local p = setmetatable({}, self)
    self.__index = self

    p.cards = {}
    p.count = 0
    p.display_height = 8 -- Regular card height

    return p
end

function Pile:push(card)
    table.insert(self.cards, card)
    self.count = self.count + 1
end

function Pile:set_cards(cards)
    self.cards = cards
    self.count = #self.cards
end

function Pile:peek()
    local card = nil

    if self.count > 0 then
        card = self.cards[self.count]
    end

    return card
end

function Pile:pop()
    local card = table.remove(self.cards, self.count)
    self.count = self.count - 1

    return card
end

function Pile:remove_at(index)
    local card = table.remove(self.cards, index)
    self.count = self.count - 1

    return card
end

function Pile:get_iterator()
    return PileIterator:new(self)
end

function Pile:render_line(index)
    if self.count == 0 then
        return EMPTY_PILE[index]
    else
        return self:peek().representation[index]
    end
end

function Pile:display_empty_pile()
    for _,v in pairs(EMPTY_PILE) do
        print(v)
    end
end

function Pile:display()
    if self.count == 0 then
        self:display_empty_pile()
        return
    end

    -- Pile not empty
    self:peek():display()
end

