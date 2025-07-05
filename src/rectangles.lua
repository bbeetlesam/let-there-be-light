local Rectangle = {}

local glyphW, glyphH = 32, 32
local chaoticRects = {}  -- jadi dictionary biar bisa multiple image

function Rectangle.initRects(id, image)
    chaoticRects[id] = {}

    for i = 0, 2 do
        chaoticRects[id][i+1] = love.graphics.newQuad(
            i * glyphW, 0,
            glyphW, glyphH,
            image:getWidth(), image:getHeight()
        )
    end
end

function Rectangle.draw(id, image, x, y, w, h, originX, originY)
    originX = originX or 0
    originY = originY or 0

    local quadList = chaoticRects[id]
    if not quadList then return end

    local quad = quadList[math.random(#quadList)]
    local tileSize = 32

    local scaleX = w / tileSize
    local scaleY = h / tileSize

    local offsetX = w * originX
    local offsetY = h * originY

    love.graphics.draw(
        image,
        quad,
        x - offsetX,
        y - offsetY,
        0,
        scaleX,
        scaleY
    )
end

return Rectangle