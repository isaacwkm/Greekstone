-- main.lua

local Card = require("card")
local Deck = require("deck")
local Player = require("player")
local UI = require("ui")
local cardData = require("card_data")
local CardEffects = require("card_effects")


local player

local selectedCard = nil
local hoveredIndex = nil
local draggingCard = nil
local dragOffsetY = 0

-- Board state: 3 locations, each with a player and AI side
local locations = {
    { cards = {}, ai = {} },
    { cards = {}, ai = {} },
    { cards = {}, ai = {} }
}

-- Layout constants
local LOCATION_WIDTH = 200
local LOCATION_HEIGHT = 100
local LOCATION_GAP = 20
local LOCATION_BASE_Y = love.graphics.getHeight() - 180 -- vertical center for location boxes
local AI_OFFSET_Y = -110
local PLAYER_OFFSET_Y = 20

local playAgainButton = {
    x = 550,
    y = 540,
    w = 300,
    h = 50
}


-- AI player and turn state
local aiPlayer = nil
local turn = 1
local maxPoints = 15

local gamePhase = "play" -- other phases: "resolving", "gameover"
local playerScore = 0
local aiScore = 0

local submitButton = { x = 1200, y = 600, w = 150, h = 50 }

function buildDeck(cardPool, size)
    local deck = {}
    local counts = {}

    while #deck < size do
        local cardData = cardPool[love.math.random(#cardPool)]
        counts[cardData.name] = (counts[cardData.name] or 0)

        if counts[cardData.name] < 2 then
            table.insert(deck, Card:new(cardData.name, cardData.cost, cardData.power, cardData.text))
            counts[cardData.name] = counts[cardData.name] + 1
        end
    end

    return deck
end

function startNextTurn()
    turn = turn + 1
    player.mana = turn
    aiPlayer.mana = turn

    player:drawCard()
    aiPlayer:drawCard()

    for _, loc in ipairs(locations) do
        loc.cards = {}
        loc.ai = {}
    end
end

function love.load()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.4) -- dark blue (RGB in 0–1 range)

    local playerDeck = Deck:new(buildDeck(cardData, 20))
    playerDeck:shuffle()

    local aiDeck = Deck:new(buildDeck(cardData, 20))
    aiDeck:shuffle()

    player = Player:new(playerDeck)     -- regular player
    aiPlayer = Player:new(aiDeck, true) -- AI player with isAI = true

    for _ = 1, 3 do
        player:drawCard()
        aiPlayer:drawCard()
    end
end

function love.update(dt)
    hoveredIndex = nil
    local mouseX, mouseY = love.mouse.getPosition()

    for i, card in ipairs(player.hand) do
        local y = 30 + (i - 1) * 60
        if mouseX >= 10 and mouseX <= 300 and mouseY >= y and mouseY <= y + 50 then
            hoveredIndex = i
            break
        end
    end
end

function love.draw()
    UI.drawText("Player Hand:", 10, 10)

    -- Draw the player's hand
    for i, card in ipairs(player.hand) do
        local y = 30 + (i - 1) * 60

        -- Set background color based on affordability
        if player.mana < card.cost then
            love.graphics.setColor(0.3, 0.3, 0.4, 0.8) -- dark gray-blue
        else
            love.graphics.setColor(0.65, 0.58, 0.45)   -- parchment tan
        end

        love.graphics.rectangle("fill", 10, y, 280, 50)

        -- Border for card readability
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("line", 10, y, 280, 50)

        -- Draw card text in off-white
        love.graphics.setColor(0.95, 0.95, 0.95)
        UI.drawText("Name: " .. card.name, 20, y + 5)
        UI.drawText("Cost: " .. card.cost .. "  Power: " .. card.power, 20, y + 20)
    end



    -- Draw board locations
    for i, loc in ipairs(locations) do
        local lx = 50 + (i - 1) * (LOCATION_WIDTH + 20)
        local ly = LOCATION_BASE_Y
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", lx, ly, LOCATION_WIDTH, LOCATION_HEIGHT)

        love.graphics.setColor(1, 1, 1)
        UI.drawText("Location " .. i, lx + 10, ly + 5)

        for j, card in ipairs(loc.cards) do
            UI.drawText(card.name, lx + 10, ly + 20 + (j - 1) * 20)
        end
    end

    -- Draw dragging card (floating with mouse)
    if draggingCard then
        local mx, my = love.mouse.getPosition()
        love.graphics.setColor(1, 1, 1)
        UI.drawText("Name: " .. draggingCard.name, mx + 10, my - dragOffsetY)
        UI.drawText("Cost: " .. draggingCard.cost .. "  Power: " .. draggingCard.power, mx + 10, my - dragOffsetY + 15)
        UI.drawText("Text: " .. draggingCard.text, mx + 10, my - dragOffsetY + 30)
    end

    -- Draw Submit Button
    love.graphics.setColor(0.2, 0.6, 1)
    love.graphics.rectangle("fill", submitButton.x, submitButton.y, submitButton.w, submitButton.h)
    love.graphics.setColor(1, 1, 1)
    local buttonLabel = "Submit"
    if gamePhase == "review" then
        buttonLabel = "Next Turn"
    elseif gamePhase == "end" then
        buttonLabel = "Restart"
    end

    UI.drawText(buttonLabel, submitButton.x + 40, submitButton.y + 15)


    -- Draw Scores
    UI.drawText("Player Score: " .. playerScore, 1050, 20)
    UI.drawText("AI Score: " .. aiScore, 1050, 50)

    -- Draw AI cards
    for i, loc in ipairs(locations) do
        local lx = 50 + (i - 1) * (LOCATION_WIDTH + 20)
        local ly = LOCATION_BASE_Y - 150
        love.graphics.setColor(0.15, 0.15, 0.15)
        love.graphics.rectangle("fill", lx, ly, LOCATION_WIDTH, LOCATION_HEIGHT)

        love.graphics.setColor(1, 1, 1)
        UI.drawText("AI Location " .. i, lx + 10, ly + 5)

        for j, card in ipairs(loc.ai) do
            UI.drawText(card.name, lx + 10, ly + 20 + (j - 1) * 20)
        end
    end

    -- UI Header
    love.graphics.setColor(1, 1, 1)
    UI.drawText("Greekstone", 800, 10)
    UI.drawText("Turn: " .. turn, 600, 30)
    UI.drawText("Mana: " .. player.mana, 600, 50)
    UI.drawText("Points to Win: " .. maxPoints, 600, 70)

    if gamePhase == "gameover" then
        local oldFont = love.graphics.getFont() -- save the current font
        local bigFont = love.graphics.newFont(48)
        love.graphics.setFont(bigFont)

        local msg = "GAME OVER! FIRST TO 15 WINS!"
        local textWidth = bigFont:getWidth(msg)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(msg, (love.graphics.getWidth() - textWidth) / 2, love.graphics.getHeight() / 2 - 24)

        love.graphics.setFont(oldFont) -- restore previous font

        -- Draw the Play Again button
        love.graphics.setColor(0.3, 0.6, 1.0)
        love.graphics.rectangle("fill", playAgainButton.x, playAgainButton.y, playAgainButton.w, playAgainButton.h, 10,
            10)
        love.graphics.setColor(1, 1, 1)
        UI.drawText("Play Again", playAgainButton.x + 90, playAgainButton.y + 15)
    end

    love.graphics.setColor(1, 1, 1) -- reset draw color
end

function love.mousepressed(x, y, button)
    if gamePhase == "gameover" then
        if x >= playAgainButton.x and x <= playAgainButton.x + playAgainButton.w and
            y >= playAgainButton.y and y <= playAgainButton.y + playAgainButton.h then
            -- Clear location cards
            for _, loc in ipairs(locations) do
                loc.cards = {}
                loc.ai = {}
            end

            -- Generate and shuffle new decks
            local playerDeck = Deck:new(buildDeck(cardData, 20))
            playerDeck:shuffle()

            local aiDeck = Deck:new(buildDeck(cardData, 20))
            aiDeck:shuffle()

            -- Recreate players
            player = Player:new(playerDeck)
            aiPlayer = Player:new(aiDeck, true)

            -- Initial hand draw
            for _ = 1, 3 do
                player:drawCard()
                aiPlayer:drawCard()
            end

            -- Reset state
            playerScore = 0
            aiScore = 0
            turn = 1
            player.mana = turn
            aiPlayer.mana = turn
            gamePhase = "play"

            return
        end
    end



    -- Handle "Next Turn" click during review
    if button == 1 and gamePhase == "review" then
        if insideSubmitButton(x, y) then
            startNextTurn() -- Draw cards, reset mana, clear boards, etc.
            gamePhase = "play"
        end
        return
    end

    -- Handle card dragging
    if button == 1 and hoveredIndex then
        draggingCard = player.hand[hoveredIndex]
        selectedCard = draggingCard
        dragOffsetY = y - (30 + (hoveredIndex - 1) * 60)
    end

    -- Handle Submit Turn
    if gamePhase == "play" and x >= submitButton.x and x <= submitButton.x + submitButton.w and
        y >= submitButton.y and y <= submitButton.y + submitButton.h then
        gamePhase = "resolving"

        -- AI randomly plays cards based on available mana
        for i = 1, 3 do
            while #locations[i].ai < 4 and aiPlayer.mana > 0 and #aiPlayer.hand > 0 do
                -- Pick a random playable card
                local validCards = {}
                for idx, card in ipairs(aiPlayer.hand) do
                    if card.cost <= aiPlayer.mana then
                        table.insert(validCards, { card = card, index = idx })
                    end
                end

                if #validCards == 0 then break end

                local pick = validCards[love.math.random(#validCards)]
                table.insert(locations[i].ai, pick.card)
                aiPlayer.mana = aiPlayer.mana - pick.card.cost
                table.remove(aiPlayer.hand, pick.index)
            end
        end


        -- Resolve all card effects
        for i, loc in ipairs(locations) do
            for _, card in ipairs(loc.cards) do
                CardEffects.resolve(card, player, aiPlayer, i, locations)
            end
            for _, card in ipairs(loc.ai) do
                CardEffects.resolve(card, aiPlayer, player, i, locations)
            end
        end

        -- Score locations
        for i, loc in ipairs(locations) do
            local pPower, aPower = 0, 0
            for _, c in ipairs(loc.cards) do pPower = pPower + c.power end
            for _, c in ipairs(loc.ai) do aPower = aPower + c.power end

            if pPower > aPower then
                playerScore = playerScore + (pPower - aPower)
            elseif aPower > pPower then
                aiScore = aiScore + (aPower - pPower)
            end
        end

        -- Remove discarded cards
        for _, loc in ipairs(locations) do
            for i = #loc.cards, 1, -1 do
                if loc.cards[i]._discard then table.remove(loc.cards, i) end
            end
            for i = #loc.ai, 1, -1 do
                if loc.ai[i]._discard then table.remove(loc.ai, i) end
            end
        end

        -- Transition to review
        gamePhase = "review"

        -- If someone won, set final phase (but do not start next turn here)
        if playerScore >= maxPoints or aiScore >= maxPoints then
            gamePhase = "gameover"
        end

        return
    end
end

function love.mousereleased(x, y, button)
    if button == 1 and draggingCard then
        for i, loc in ipairs(locations) do
            local lx = 50 + (i - 1) * (LOCATION_WIDTH + 20)
            local ly = LOCATION_BASE_Y
            if x >= lx and x <= lx + LOCATION_WIDTH and y >= ly and y <= ly + LOCATION_HEIGHT then
                if #loc.cards < 4 then
                    if player.mana >= draggingCard.cost then
                        -- Play the card
                        player.mana = player.mana - draggingCard.cost
                        table.insert(loc.cards, draggingCard)

                        -- Remove from hand
                        for h = #player.hand, 1, -1 do
                            if player.hand[h] == draggingCard then
                                table.remove(player.hand, h)
                                break
                            end
                        end
                    else
                        -- Optional: Show error or feedback
                        print("Not enough mana!")
                    end
                end
            end
        end
        draggingCard = nil
    end
end

function insideSubmitButton(x, y)
    return x >= submitButton.x and x <= submitButton.x + submitButton.w and
        y >= submitButton.y and y <= submitButton.y + submitButton.h
end
