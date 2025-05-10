Family = {
    name = nil,
    symbol = nil,
    colour = nil
}

function Family:new(name, symbol, colour)
    local f = setmetatable({}, self)
    self.__index = self

    f.name = name
    f.symbol = symbol
    f.colour = colour or ""

    return f
end

