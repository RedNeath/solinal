require 'command'

Supply = Command:new()

function Supply:new(game)
    local s = setmetatable({}, self)
    self.__index = self

    s.game = game

    return s
end

function Supply:refill_stock_pile()
    while self.game.supply_pile.count > 0 do
        local card = self.game.supply_pile:pop()
        card:flip()
        self.game.stock_pile:push(card)
    end
end

function Supply:refill_supply_pile()
    while self.game.stock_pile.count > 0 do
        local card = self.game.stock_pile:pop()
        card:flip()
        self.game.supply_pile:push(card)
    end
end

function Supply:execute()
    if self.game.stock_pile.count == 0 then
        self:refill_stock_pile()
    else
        local card = self.game.stock_pile:pop()
        card:flip()
        self.game.supply_pile:push(card)
    end
end

function Supply:undo()
    if self.game.supply_pile.count == 0 then
        self:refill_supply_pile()
    else
        local card = self.game.supply_pile:pop()
        card:flip()
        self.game.stock_pile:push(card)
    end
end

