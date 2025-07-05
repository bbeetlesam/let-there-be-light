local SpriteFont = {}
SpriteFont.__index = SpriteFont

function SpriteFont:new(imagePaths, glyphWs, glyphHs, cols, rows, fps)
    local self = setmetatable({}, SpriteFont)

    self.images = {}
    self.quads = {}
    self.glyphWs = glyphWs
    self.glyphHs = glyphHs
    self.cols = cols
    self.rows = rows
    self.fps = fps or 10 -- how many times it changes per second
    self.frameCounter = 0

    -- ensure input is table
    if type(imagePaths) ~= "table" then imagePaths = {imagePaths} end
    if type(glyphWs) ~= "table" then glyphWs = {glyphWs} end
    if type(glyphHs) ~= "table" then glyphHs = {glyphHs} end

    for i, path in ipairs(imagePaths) do
        local img = love.graphics.newImage(path)
        table.insert(self.images, img)

        local glyphW = glyphWs[i] or glyphWs[1]
        local glyphH = glyphHs[i] or glyphHs[1]
        local quads = {}
        local startAscii = 32
        local totalGlyphs = 96

        for j = 0, totalGlyphs - 1 do
            local col = j % cols
            local row = math.floor(j / cols)

            quads[startAscii + j] = love.graphics.newQuad(
                col * glyphW,
                row * glyphH,
                glyphW,
                glyphH,
                img:getWidth(),
                img:getHeight()
            )
        end

        table.insert(self.quads, quads)
    end

    return self
end

function SpriteFont:update(dt)
    self.frameCounter = self.frameCounter + dt * (self.fps or 0)
end

function SpriteFont:print(text, x, y, scale, originX, originY)
    scale = scale or 1
    originX = originX or 0
    originY = originY or 0

    local textWidth = #text * self.glyphWs[1] * scale
    local textHeight = self.glyphHs[1] * scale

    local offsetX = textWidth * originX
    local offsetY = textHeight * originY

    for i = 1, #text do
        local char = text:sub(i, i)
        local ascii = char:byte()
        if ascii < 32 or ascii > 126 then goto continue end

        -- select frame index based on time or random
        local fontIndex = math.floor(self.frameCounter + i) % #self.images + 1

        local quad = self.quads[fontIndex][ascii]
        local image = self.images[fontIndex]

        if quad then
            love.graphics.draw(
                image,
                quad,
                x - offsetX + (i - 1) * self.glyphWs[1] * scale,
                y - offsetY,
                0,
                scale,
                scale
            )
        end

        ::continue::
    end
end

return SpriteFont