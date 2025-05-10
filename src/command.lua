Command = {}

function Command:new()
    local c = setmetatable({}, self)
    self.__index = self

    return c
end

function Command:execute()
    return
end

function Command:undo()
    return
end

