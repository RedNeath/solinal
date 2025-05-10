require 'pile'

SpreadedPile = Pile:new()

function SpreadedPile:display()
    if self.count == 0 then
        self:display_empty_pile()
        return
    end

    -- Pile not empty
    for k,v in pairs(self.cards) do
        if k == self.count then
            v:display()
        else
            v:display_short()
        end
    end
end

