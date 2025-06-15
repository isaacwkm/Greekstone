-- card_effects.lua

local CardEffects = {}

function CardEffects.resolve(card, player, opponent, locationIndex, locations)
    if card.effectType == "onReveal" then
        CardEffects.resolveOnReveal(card, player, opponent, locationIndex, locations)
    elseif card.effectType == "endOfTurn" then
        CardEffects.resolveEndOfTurn(card, player, opponent, locationIndex, locations)
    end
end

function CardEffects.resolveOnReveal(card, player, opponent, locationIndex, locations)
    local loc = locations[locationIndex]

    if card.name == "Zeus" then
        for _, c in ipairs(opponent.hand) do
            c.power = math.max(0, c.power - 1)
        end

    elseif card.name == "Ares" then
        local enemies = player.isAI and loc.cards or loc.ai
        card.power = card.power + (2 * #enemies)

    elseif card.name == "Hera" then
        for _, c in ipairs(player.hand) do
            c.power = c.power + 1
        end

    elseif card.name == "Demeter" then
        player:drawCard()
        opponent:drawCard()

    elseif card.name == "Hades" then
        if player.discard then
            card.power = card.power + (2 * #player.discard)
        end

    elseif card.name == "Hercules" then
        local allCards = {}
        for _, c in ipairs(loc.cards) do table.insert(allCards, c) end
        for _, c in ipairs(loc.ai) do table.insert(allCards, c) end
        local max = 0
        for _, c in ipairs(allCards) do if c.power > max then max = c.power end end
        if card.power >= max then card.power = card.power * 2 end

    elseif card.name == "Dionysus" then
        local allies = player.isAI and loc.ai or loc.cards
        card.power = card.power + (2 * (#allies - 1))

    elseif card.name == "Hermes" then
        local target = (locationIndex % 3) + 1
        local list = player.isAI and locations[locationIndex].ai or locations[locationIndex].cards
        for i = #list, 1, -1 do
            if list[i] == card then table.remove(list, i) break end
        end
        table.insert(player.isAI and locations[target].ai or locations[target].cards, card)

    elseif card.name == "Poseidon" then
        local enemies = player.isAI and loc.cards or loc.ai
        local weakest = nil
        for i, c in ipairs(enemies) do
            if not weakest or c.power < weakest.power then
                weakest = c
            end
        end
        for i = #enemies, 1, -1 do
            if enemies[i] == weakest then table.remove(enemies, i) break end
        end

    elseif card.name == "Artemis" then
        local enemies = player.isAI and loc.cards or loc.ai
        if #enemies == 1 then
            card.power = card.power + 5
        end

    elseif card.name == "Persephone" then
        local minPower, minIndex = math.huge, nil
        for i, c in ipairs(player.hand) do
            if c.power < minPower then
                minPower = c.power
                minIndex = i
            end
        end
        if minIndex then table.remove(player.hand, minIndex) end

    elseif card.name == "Pandora" then
        local allies = player.isAI and loc.ai or loc.cards
        if #allies <= 1 then
            card.power = card.power - 5
        end

    elseif card.name == "Midas" then
        for _, c in ipairs(loc.cards) do c.power = 3 end
        for _, c in ipairs(loc.ai) do c.power = 3 end

    elseif card.name == "Aphrodite" then
        local enemies = player.isAI and loc.cards or loc.ai
        for _, c in ipairs(enemies) do
            c.power = math.max(0, c.power - 1)
        end

    elseif card.name == "Hephaestus" then
        local shuffled = {}
        for i, c in ipairs(player.hand) do table.insert(shuffled, c) end
        for i = #shuffled, 2, -1 do
            local j = love.math.random(i)
            shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
        end
        for i = 1, math.min(2, #shuffled) do
            shuffled[i].cost = math.max(0, shuffled[i].cost - 1)
        end

    elseif card.name == "Ship of Theseus" then
        local copy = Card:new(card.name, card.cost, card.power + 1, card.text)
        table.insert(player.hand, copy)

    elseif card.name == "Daedalus" then
        for i, l in ipairs(locations) do
            if i ~= locationIndex then
                local cow = Card:new("Wooden Cow", 1, 1, "")
                table.insert(player.isAI and l.ai or l.cards, cow)
            end
        end

    elseif card.name == "Mnemosyne" and player.lastPlayedCard then
        local copy = Card:new(player.lastPlayedCard.name, player.lastPlayedCard.cost, player.lastPlayedCard.power, player.lastPlayedCard.text)
        table.insert(player.hand, copy)
    end
end


function CardEffects.resolveEndOfTurn(card, player, opponent, locationIndex, locations)
    local loc = locations[locationIndex]
    local allies = player.isAI and loc.ai or loc.cards
    local enemies = player.isAI and loc.cards or loc.ai

    if card.name == "Sword of Damocles" then
        local pPower, aPower = 0, 0
        for _, c in ipairs(loc.cards) do pPower = pPower + c.power end
        for _, c in ipairs(loc.ai) do aPower = aPower + c.power end
        local winning = (player.isAI and aPower > pPower) or (not player.isAI and pPower > aPower)
        if not winning then card.power = card.power - 1 end

    elseif card.name == "Icarus" then
        card.power = card.power + 1
        if card.power > 7 then card._discard = true end

    elseif card.name == "Helios" then
        card._discard = true

    elseif card.name == "Iris" then
        -- Boost all allies in OTHER locations if they have unique powers
        local function isUnique(card, cardList)
            local count = 0
            for _, c in ipairs(cardList) do
                if c.power == card.power then count = count + 1 end
            end
            return count == 1
        end

        for i, otherLoc in ipairs(locations) do
            if i ~= locationIndex then
                local targetList = player.isAI and otherLoc.ai or otherLoc.cards
                for _, c in ipairs(targetList) do
                    if isUnique(c, targetList) then c.power = c.power + 1 end
                end
            end
        end

    elseif card.name == "Altas" then
        if #allies >= 4 then
            card.power = card.power - 1
        end
    end
end

function CardEffects.applyPassiveOnPlay(location, playedCard, owner)
    for _, card in ipairs(location.cards) do
        if card.name == "Medusa" and card ~= playedCard then
            playedCard.power = playedCard.power - 1
        end
        if card.name == "Athena" and owner == "player" and card ~= playedCard then
            card.power = card.power + 1
        end
    end
end


return CardEffects
