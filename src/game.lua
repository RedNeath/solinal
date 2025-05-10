require 'command_manager'
require 'pile'
require 'spreaded_pile'
require 'family'
require 'card'

Game = {
    command_manager = nil,
    stock_pile = nil,
    supply_pile = nil,
    pit = nil,
    board = nil
}

function Game:new(game_settings)
    local g = setmetatable({}, self)
    self.__index = self

    g.command_manager = CommandManager:new(game_settings.history_size)
    g.stock_pile = Pile:new()
    g.supply_pile = Pile:new()

    g.pit = {
        Pile:new(),
        Pile:new(),
        Pile:new(),
        Pile:new(),
    }

    g.board = {
        SpreadedPile:new(),
        SpreadedPile:new(),
        SpreadedPile:new(),
        SpreadedPile:new(),
        SpreadedPile:new(),
        SpreadedPile:new(),
        SpreadedPile:new()
    }

    g:initialise()

    return g
end

function Game:initialise()
    -- Let's create the deck and shuffle it first!
    local deck = shuffle_deck(create_deck())

    -- Then let's add cards to each pile
    local pile_index = 1
    local line_index = 1

    while line_index <= #self.board do
        while pile_index <= #self.board do
            local picked_card = table.remove(deck, 1)

            if pile_index == line_index then
                picked_card:flip()
            end

            self.board[pile_index]:push(picked_card)
            pile_index = pile_index + 1
        end

        line_index = line_index + 1
        pile_index = line_index
    end

    -- And finally, let's add the remaining cards to the stock pile.
    self.stock_pile:set_cards(deck)
end

-- soon deprecated (made for debug purposes)
function Game:display()
    for k,v in pairs(self.board) do
        print("Board pile no. " .. k)
        v:display()
        print()
    end

    print("Stock pile")
    self.stock_pile:display()
    print()

    print("Supply pile")
    self.supply_pile:display()
    print()

    for k,v in pairs (self.pit) do
        print("Pit pile no. " .. k)
        v:display()
        print()
    end
end


-- UTILITY FUNCTIONS --

function shuffle_deck(cards)
    math.randomseed(os.time())
    shuffled = {}
    for i, v in ipairs(cards) do
	    local pos = math.random(1, #shuffled+1)
	    table.insert(shuffled, pos, v)
    end

    return shuffled
end

function create_deck()
    local cards = {}

    local family_table = {
        { name = "C", symbol = "♣", colour = "" },
        { name = "S", symbol = "♠", colour = "" },
        { name = "H", symbol = "♥", colour = "\027[31m" },
        { name = "D", symbol = "♦", colour = "\027[31m" },
    }

    for _,f in pairs(family_table) do
        local family_cards = create_family_cards(f.name, f.symbol, f.colour)
        for _,c in pairs(family_cards) do
            table.insert(cards, c)
        end
    end

    return cards
end

function create_family_cards(name, symbol, colour)
    local family = Family:new(name, symbol, colour)

    return {
        Card:new(family, "A", nil),
        Card:new(family, "2", nil),
        Card:new(family, "3", nil),
        Card:new(family, "4", nil),
        Card:new(family, "5", nil),
        Card:new(family, "6", nil),
        Card:new(family, "7", nil),
        Card:new(family, "8", nil),
        Card:new(family, "9", nil),
        Card:new(family, "10", nil),
        Card:new(family, "J", nil),
        Card:new(family, "Q", nil),
        Card:new(family, "K", nil)
    }
end

