-- deck.lua

local Deck = {}
Deck.__index = Deck

function Deck:new(cards)
    local deck = setmetatable({}, Deck)
    deck.cards = cards or {}
    return deck
end

function Deck:shuffle()
    for i = #self.cards, 2, -1 do
        local j = math.random(i)
        self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
    end
end

function Deck:draw()
    return table.remove(self.cards)
end

return Deck
