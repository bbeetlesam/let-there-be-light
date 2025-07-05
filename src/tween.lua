Tween = {}
Tween.__index = Tween

function Tween:new(startValue, endValue, duration, easing)
    local t = {
        startValue = startValue,
        endValue = endValue,
        duration = duration,
        easing = easing or function(t) return t end, -- default easing func - linear
        time = 0,
        value = startValue,
        finished = false,
    }
    setmetatable(t, self)
    return t
end

function Tween:update(dt)
    if self.finished then return end

    self.time = self.time + dt
    local t = math.min(self.time / self.duration, 1)
    self.value = self.startValue + (self.endValue - self.startValue) * self.easing(t)

    if t >= 1 then
        self.finished = true
    end
end

function Tween:isFinished()
    return self.finished
end

function Tween:reset(startValue, endValue, duration)
    self.startValue = startValue or self.startValue
    self.endValue = endValue or self.endValue
    self.duration = duration or self.duration
    self.time = 0
    self.finished = false
end

return Tween