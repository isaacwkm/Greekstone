-- game.lua

local Game = {}
Game.__index = Game

function Game:new(player1, player2)
    local game = setmetatable({}, Game)
    game.players = {player1, player2}
    game.turn = 1
    game.state = "start"
    return game
end

function Game:update(dt)
    -- TODO: implement phase transitions
end

function Game:draw()
    -- TODO: implement minimal draw for player hands and UI
end

return Game
