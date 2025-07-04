local const = require("src.const")

local Camera = {}
Camera.__index = Camera

function Camera:new(x, y, zoom)
    local self = setmetatable({}, Camera)
    self.x = x or 0
    self.y = y or 0
    self.zoom = zoom or 1
    return self
end

function Camera:setPosition(x, y)
    self.x = x or 0
    self.y = y or 0
end

function Camera:getPosition()
    return self.x, self.y
end

function Camera:setZoom(zoom)
    self.zoom = zoom or 1
end

function Camera:attach()
    love.graphics.push()

    -- translate to center screen
    love.graphics.translate(const.GAME_WIDTH / 2, const.GAME_HEIGHT / 2)

    -- scale/zoom based on the point
    love.graphics.scale(self.zoom, self.zoom)

    -- return translate, then move view based on camera position
    love.graphics.translate(-self.x, -self.y)
end

function Camera:detach()
    love.graphics.pop()
end

return Camera