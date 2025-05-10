Pile = {
    cards = {},
    count = 0
}

local empty_pile = {
    "+   -   +",
    "         ",
    "         ",
    "|       |",
    "         ",
    "         ",
    "         ",
    "+   -   +"
}

function Pile:new()
    local p = setmetatable({}, self)
    self.__index = self

    p.cards = {}
    p.count = 0

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
    return self.cards[self.count]
end

function Pile:pop()
    local card = table.remove(self.cards, self.count)
    self.count = self.count - 1

    return card
end

function Pile:display_empty_pile()
    for _,v in pairs(empty_pile) do
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

