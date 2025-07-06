local Interactables = {}
Interactables.__index = Interactables

function Interactables:new()
    local self = setmetatable({}, Interactables)
    self.objects = {}
    return self
end

function Interactables:add(id, x, y, radius, image, callback, mode, drawConf, onLeave, enabled)
    self.objects[id] = {
        id = id,
        x = x,
        y = y,
        radius = radius,
        triggered = false,
        callback = callback,
        onLeave = onLeave,
        image = image,
        mode = mode or "once",
        drawConf = drawConf or {0, 1, 1},
        enabled = enabled,
        inRange = false
    }
end

function Interactables:update(playerX, playerY)
    for _, obj in pairs(self.objects) do
        if obj.enabled then
            local dx = obj.x - playerX
            local dy = obj.y - playerY
            local dist = math.sqrt(dx * dx + dy * dy)
            local wasInRange = obj.inRange
            local nowInRange = dist <= obj.radius

            -- enter area
            if nowInRange then
                if obj.mode == "once" and not obj.triggered then
                    obj.triggered = true
                    if obj.callback then obj.callback() end
                elseif obj.mode == "while" then
                    if obj.callback then obj.callback() end
                end
            end

            -- leave area
            if not nowInRange then
                if obj.mode == "while" and obj.onLeave then
                    obj.onLeave()
                end
                if obj.mode == "once" and wasInRange and obj.onLeave then
                    obj.onLeave()
                end
            end

            obj.inRange = nowInRange
        end
    end
end

function Interactables:enable(id)
    if self.objects[id] then
        self.objects[id].enabled = true
    end
end

function Interactables:disable(id)
    if self.objects[id] then
        self.objects[id].enabled = false
    end
end

function Interactables:get(id)
    local obj = self.objects[id]
    if not obj then return nil end
    return obj.triggered
end

function Interactables:getClosest(playerX, playerY)
    local closestId = nil
    local closestDist = math.huge

    for id, obj in pairs(self.objects) do
        local dx = obj.x - playerX
        local dy = obj.y - playerY
        local dist = math.sqrt(dx * dx + dy * dy)

        if dist <= obj.radius and dist < closestDist then
            closestDist = dist
            closestId = id
        end
    end

    return closestId, closestDist
end

function Interactables:getImage(id)
    local obj = self.objects[id]
    return obj.image
end

function Interactables:draw()
    for _, obj in pairs(self.objects) do
        if obj.image and love.graphics.isCreated(obj.image) then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(obj.image, obj.x, obj.y, obj.drawConf[1], obj.drawConf[2], obj.drawConf[3], obj.image:getWidth()/2, obj.image:getHeight()/2)
        else
            -- fallback
            love.graphics.setColor(1, 1, 1, 0.1)
            love.graphics.circle("line", obj.x, obj.y, obj.radius)
        end
    end
end

return Interactables