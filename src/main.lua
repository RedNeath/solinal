require 'commands.supply'

require 'game'
require 'game_settings'


local command_table = {
    supply = function (game, args)
                 return Supply:new(game)
             end,

    moveto = function (game, args)
                 return nil
             end,
}

function match_command(game, input)
    if command_table[input] then
        return command_table[input](game, nil)
    else
        return nil
    end
end



-- By default, we create a new game with default settings (settings.json)
-- when starting the programme.
local game_settings = GameSettings:new()
local game = Game:new(game_settings)
local exiting = false

game:display()

-- Here is the main programme loop. It is looping until the user explicitly
-- asks for it to stop
while not exiting do
    local input = io.read("*l")
    local game_command = match_command(game, input)

    if game_command then
        game.command_manager:execute_command(game_command)
    elseif not game_command and input == "exit" then
        break
    elseif not game_command and input == "newgame" then
        game = Game:new(game_settings)
    else
        print("No command was recognised. Please try again")
    end

    -- At the end of the turn, we display the game, no matter what.
    game:display()
end

