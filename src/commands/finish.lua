require 'command'
require 'commands.supply'
require 'commands.moveto'

function sleep(seconds)
    local t0 = os.clock()
    while os.clock() - t0 <= seconds do end
end

Finish = Command:new()

function Finish:new(game)
    local f = setmetatable({}, self)
    self.__index = self

    f.name = "finish"
    f.game = game

    -- Ignoring passed parameters

    return f
end

function Finish:execute()
    if not self.game:all_cards_upwards() then
        return
    end

    -- The strategy is to keep each pile at the same
    -- value in the pit.
    local lowest_pit = self.game:get_lowest_pit_index()
    local pit_card = self.game.pit[lowest_pit]:peek()
    while pit_card:continuous_value() < 13 do
        local target_card_id = pit_card.family.name .. pit_card:text_value

        -- Making sure the sought card is available before moving it
        while not target_card do
            -- We move cards from the stock pile to the supply pile
            sleep(self.game.settings.display_delay_seconds)
            
            -- By lazyiness, we just create a supply command and execute it
            local command = Supply:new(self.game)
            command:execute()
            self.game:display()

            target_card = self.game:find_card_by_id(target_card_id)
        end

        sleep(self.game.settings.display_delay_seconds)
        local command = Moveto:new(self.game, { target_card_id, "P" .. lowest_pit })
        command:execute()
        self.game:display()

        lowest_pit = self.game:get_lowest_pit_index()
        pit_card = self.game.pit[lowest_pit]:peek()
    end
end

function Finish:undo()
    print("Not implemented yet")
end
