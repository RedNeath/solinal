-- We need to do this before importing anything
package.path = "../share/lua/5.4/?.lua"
    .. ";../share/lua/5.4/?/init.lua"
    .. ";../lib/lua/5.4/?.lua"
    .. ";../lib/lua/5.4/?/init.lua;"
    .. package.path
    .. ";../lib/lua/5.4/?.so"
    .. ";../lib/lua/5.4/loadall.so"
    .. ";../bin/?.so"

require 'commands.moveto'
require 'commands.supply'

require 'game'
require 'game_settings'

local split = require 'split'.split


local command_table = {
    supply= function (game, args)
                return Supply:new(game)
            end,

    moveto= function (game, args)
                return Moveto:new(game, args)
            end,
}

function match_command(game, user_input)
    local args = split(user_input, ' ')
    local input = table.remove(args, 1)

    if command_table[input] then
        return command_table[input](game, args)
    else
        return nil
    end
end


-- By default, we create a new game with default settings (settings.json)
-- when starting the programme.
local game_settings = GameSettings:new()
local game = Game:new(game_settings)
local exiting = false

game:display(true)

-- Here is the main programme loop. It is looping until the user explicitly
-- asks for it to stop
while not exiting do
    io.write(">>> ")
    local input = io.read("*l")
    local game_command = match_command(game, input)
    local last_command = game.command_manager:get_last_command()

    if last_command and not game_command and input == "" then
        game_command = match_command(game, last_command:get_name())
    end

    if game_command then
        game.command_manager:execute_command(game_command)
    elseif not game_command and input == "undo" then
        game.command_manager:undo_last_command()
    elseif not game_command and input == "exit" then
        break
    elseif not game_command and input == "newgame" then
        game = Game:new(game_settings)
    else
        print("No command was recognised. Please try again")
    end

    -- At the end of the turn, we display the game, no matter what.
    game:display(true)
end

