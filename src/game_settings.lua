local ljson = require 'lunajson'

GameSettings = {}

function GameSettings:new()
    -- reading the settings.json file
    local settings_file = io.open("../settings.json", "r")
    local json_settings = settings_file:read("*all")

    local settings_table = ljson.decode(json_settings)
    settings_file:close()

    local gs = setmetatable(settings_table, self)
    self.__index = self
    return gs
end

