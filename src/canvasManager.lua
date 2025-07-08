local CanvasManager = {}
CanvasManager.__index = CanvasManager

function CanvasManager:new()
    local self = setmetatable({}, CanvasManager)
    self.canvases = {}
    return self
end

function CanvasManager:create(name, width, height, scale, filter)
    width = width or love.graphics.getWidth()
    height = height or love.graphics.getHeight()
    scale = scale or 1
    filter = filter or {"nearest", "nearest"}

    local canvas = love.graphics.newCanvas(width, height)
    canvas:setFilter(filter[1], filter[1])
    self.canvases[name] = {
        base = canvas,
        shaders = {},
        scale = scale or 1,
    }
end

function CanvasManager:get(name)
    return self.canvases[name] and self.canvases[name].base or nil
end

function CanvasManager:addShader(name, shader)
    if self.canvases[name] then
        if type(shader) == "table" then
            for _, s in ipairs(shader) do
                table.insert(self.canvases[name].shaders, s)
            end
        else
            table.insert(self.canvases[name].shaders, shader)
        end
    end
end

function CanvasManager:clearShaders(name)
    if self.canvases[name] then
        self.canvases[name].shaders = {}
    end
end

function CanvasManager:setScale(name, scale)
    if self.canvases[name] then
        self.canvases[name].scale = scale or 1
    end
end

function CanvasManager:with(name, drawFunc)
    local canvasData = self.canvases[name]
    if canvasData then
        love.graphics.setCanvas(canvasData.base)
        love.graphics.push()
        love.graphics.clear()
        love.graphics.setColor(1, 1, 1)
        drawFunc()
        love.graphics.setColor(1, 1, 1)
        love.graphics.pop()
        love.graphics.setCanvas()
    end
end

function CanvasManager:drawAll(offsetX, offsetY)
    local offsetX = offsetX or 0
    local offsetY = offsetY or 0

    for _, canvasData in pairs(self.canvases) do
        local resultCanvas = canvasData.base

        for _, shader in ipairs(canvasData.shaders) do
            local temp = love.graphics.newCanvas(resultCanvas:getWidth(), resultCanvas:getHeight())
            love.graphics.setCanvas(temp)
            love.graphics.clear()
            love.graphics.setShader(shader)
            love.graphics.draw(resultCanvas)
            love.graphics.setShader()
            love.graphics.setCanvas()
            resultCanvas = temp
        end

        love.graphics.draw(resultCanvas, offsetX, offsetY, 0, canvasData.scale or 1, canvasData.scale or 1)
        love.graphics.setColor(1, 1, 1)
    end
end

return CanvasManager