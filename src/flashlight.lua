local Flashlight = {}
Flashlight.__index = Flashlight

function Flashlight:new()
    local self = setmetatable({}, Flashlight)
    self.instances = {}
    return self
end

function Flashlight:add(x, y)
    local light = {
        x = x,
        y = y
    }
    setmetatable(light, {
        __index = {
            getDistanceTo = function(self, px, py)
                local dx, dy = px - self.x, py - self.y
                return math.sqrt(dx * dx + dy * dy)
            end,
            draw = function(self)
                love.graphics.setColor(1.0, 0.9, 0.7, 0.2)
                love.graphics.circle("fill", self.x, self.y, 5)
                love.graphics.setColor(1, 1, 1)
            end
        }
    })

    table.insert(self.instances, light)
    return light
end

function Flashlight:getClosest(x, y)
    local closest = nil
    local minDist = math.huge

    for _, light in ipairs(self.instances) do
        local dist = light:getDistanceTo(x, y)
        if dist < minDist then
            minDist = dist
            closest = light
        end
    end

    return closest, minDist
end

function Flashlight:drawAll()
    for _, light in ipairs(self.instances) do
        light:draw()
    end
end

return Flashlight