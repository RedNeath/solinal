PileIterator = {
    pile = nil,
    index = 0
}

function PileIterator:new(pile)
    local pi = setmetatable({}, self)
    self.__index = self

    pi.pile = pile
    pi.index = 0

    return pi
end

function PileIterator:has_next()
    return self.index + 1 <= self.pile.display_height
end

function PileIterator:next()
    self.index = self.index + 1

    if self.index <= self.pile.display_height then
        return self.pile:render_line(self.index)
    else
        return "         "
    end
end
