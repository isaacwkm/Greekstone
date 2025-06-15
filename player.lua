-- player.lua

local Player = {}
Player.__index = Player

function Player:new(deck, isAI)
    local player = setmetatable({}, Player)
    player.deck = deck
    player.hand = {}
    player.mana = 0
    player.points = 0
    player.isAI = isAI or false
    return player
end

function Player:drawCard()
    if #self.hand < 7 then
        local card = self.deck:draw()
        if card then
            table.insert(self.hand, card)
        end
    end
end

return Player
