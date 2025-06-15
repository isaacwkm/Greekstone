-- card.lua

local Card = {}
Card.__index = Card

function Card:new(name, cost, power, text)
    local card = setmetatable({}, Card)
    card.name = name
    card.cost = cost
    card.power = power
    card.text = text
    return card
end

return Card
