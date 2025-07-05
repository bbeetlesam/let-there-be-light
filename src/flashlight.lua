local Flashlight = {}
Flashlight.__index = Flashlight
Flashlight.instances = {}

function Flashlight:new(x, y)
    local self = setmetatable({}, Flashlight)
    self.x = x
    self.y = y
    table.insert(Flashlight.instances, self)
    return self
end

function Flashlight:update(dt)
end

function Flashlight:draw()
    love.graphics.setColor(1.0, 0.9, 0.7, 0.2) -- soft warm yellowish light
    love.graphics.circle("fill", self.x, self.y, 5)
    love.graphics.setColor(1, 1, 1)
end

function Flashlight:drawALl()
    for _, f in ipairs(Flashlight.instances) do
        f:draw()
    end
end

function Flashlight:getPosition()
    return self.x, self.y
end

function Flashlight:getDistanceTo(x, y)
    local dx, dy = x - self.x, y - self.y
    return math.sqrt(dx*dx + dy*dy)
end

-- static func to find closest to a point
function Flashlight:getClosest(x, y)
    local closest = nil
    local minDist = math.huge

    for _, light in ipairs(Flashlight.instances) do
        local dist = light:getDistanceTo(x, y)
        if dist < minDist then
            minDist = dist
            closest = light
        end
    end

    return closest, minDist
end

return Flashlight