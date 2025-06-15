-- ui.lua

local UI = {}

function UI.drawText(text, x, y)
    love.graphics.print(text, x, y)
end

return UI
