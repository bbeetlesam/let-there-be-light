local utils = require("src.utils")

local atlas = love.graphics.newImage("assets/img/sprite-maro.png")
local quads = {}

local frameSize = 64
local columns, rows = 4, 4
for y = 0, rows - 1 do
    quads[y + 1] = {} -- (y+1)th row for certain anim (idle, walk, etc)
    for x = 0, columns - 1 do
        local quad = love.graphics.newQuad(
            x * frameSize, -- x pos in atlas
            y * frameSize, -- y pos in atlas
            frameSize, -- quad's width
            frameSize, -- quad's height
            atlas:getDimensions()
        )
        table.insert(quads[y + 1], quad)
    end
end

local walkSprite = utils.animateSpritesheet(quads[1], "forth", 9)
local idleSprite = utils.animateSpritesheet(quads[2], "forth", 9)
local walkUpSprite = utils.animateSpritesheet(quads[3], "forth", 9)
local walkDownSprite = utils.animateSpritesheet(quads[4], "forth", 9)

local Player = {}
Player.__index = Player

local State = {
    IDLE = "idle",
    WALK = "walk",
    CROUCH = "crouch"
}

local Direction = {
    UP = "up",
    DOWN = "down",
    LEFT = "left",
    RIGHT = "right",
}

function Player:new(x, y, speed, bool)
    local self = setmetatable({}, Player)
    self.x = x or 0
    self.y = y or 0
    self.speed = speed or 60
    self.playable = bool

    self.boundX = nil
    self.boundY = nil
    self.boundW = nil
    self.boundH = nil

    self.limitMinX = nil
    self.limitMaxX = nil
    self.limitMinY = nil
    self.limitMaxY = nil
    return self
end

function Player:update(dt)
    local dx, dy = 0, 0
    local left, right, up, down

    -- character's movement
    if self.playable then
        left  = love.keyboard.isDown("a")
        right = love.keyboard.isDown("d")
        up = love.keyboard.isDown("w")
        down = love.keyboard.isDown("s")
    end

    if up then dy = dy - 1 end
    if down then dy = dy + 1 end
    if left then dx = dx - 1 end
    if right then dx = dx + 1 end

    -- normalize vector (for diagonal movement)
    local length = math.sqrt(dx * dx + dy * dy)
    if length > 0 then
        dx = dx / length
        dy = dy / length
    end

    -- player's pos update
    local nextX = self.x + dx * self.speed * dt
    local nextY = self.y + dy * self.speed * dt
    self.clampedX, self.clampedY = false, false
    if self.boundX and self.boundY and self.boundW and self.boundH then
        self.clampedX = nextX < self.boundX or nextX > self.boundX + self.boundW
        self.clampedY = nextY < self.boundY or nextY > self.boundY + self.boundH

        self.x = math.max(self.boundX, math.min(nextX, self.boundX + self.boundW))
        self.y = math.max(self.boundY, math.min(nextY, self.boundY + self.boundH))
    else
        self.x = nextX
        self.y = nextY
    end

    -- hard limit boundary
    if self.limitMinX and self.limitMaxX then
        self.x = math.max(self.limitMinX, math.min(self.x, self.limitMaxX))
    end
    if self.limitMinY and self.limitMaxY then
        self.y = math.max(self.limitMinY, math.min(self.y, self.limitMaxY))
    end

    local moving = left or right or up or down
    local idle_move = left and right and not down and not up
    self.state = (moving and not idle_move) and State.WALK or State.IDLE

    if moving and not idle_move then
        if left then
            self.directionX = Direction.LEFT
        elseif right then
            self.directionX = Direction.RIGHT
        end
    end

    self.directionY = up and Direction.UP or down and Direction.DOWN or nil

    walkSprite:update(dt)
    idleSprite:update(dt)
    walkUpSprite:update(dt)
    walkDownSprite:update(dt)

    self.dx, self.dy = dx, dy
end

function Player:draw()
    local flipx = 1
    if self.directionX == Direction.LEFT then flipx = -1 end
    if self.directionX == Direction.RIGHT then flipx = 1 end

    love.graphics.setColor(1, 1, 1)
    if self.state == State.WALK then
        if self.directionY == Direction.UP then
            love.graphics.draw(atlas, walkUpSprite:getFrame(), self.x, self.y, 0, flipx * 0.85, .85, 32, 32)
        elseif self.directionY == Direction.DOWN then
            love.graphics.draw(atlas, walkDownSprite:getFrame(), self.x, self.y, 0, flipx * 0.85, .85, 32, 32)
        else
            love.graphics.draw(atlas, walkSprite:getFrame(), self.x, self.y, 0, flipx * 0.85, .85, 32, 32)
        end
    elseif self.state == State.IDLE then
        love.graphics.draw(atlas, idleSprite:getFrame(), self.x, self.y, 0, flipx * 0.85, .85, 32, 32)
    end
end

function Player:getPosition()
    return self.x + 0/2, self.y + 0/2
end

function Player:getState()
    return self.state
end

function Player:setPlayable(bool)
    self.playable = bool or false
end

function Player:setSpeed(speed)
    self.speed = speed or 60
end

function Player:getDirection()
    return self.dx, self.dy
end

function Player:setBoundary(x, y, w, h)
    self.boundX = x and (x - w/2) or nil
    self.boundY = x and (y - h/2) or nil
    self.boundW = w or nil
    self.boundH = h or nil
end

function Player:setHardLimits(minX, maxX, minY, maxY)
    self.limitMinX = minX
    self.limitMaxX = maxX
    self.limitMinY = minY
    self.limitMaxY = maxY
end

function Player:willHitLimit()
    local nextX = self.x + self.dx
    local nextY = self.y + self.dy

    local hitX = false
    local hitY = false

    if self.limitMinX and self.limitMaxX then
        hitX = nextX < self.limitMinX or nextX > self.limitMaxX
    end
    if self.limitMinY and self.limitMaxY then
        hitY = nextY < self.limitMinY or nextY > self.limitMaxY
    end

    return hitX or hitY
end

function Player:isInsideBoundary()
    return utils.isPosInside({self.x, self.y}, self.boundX - self.boundW/2, self.boundY - self.boundH/2, self.boundW, self.boundH)
end

function Player:isClamped()
    return self.clampedX or self.clampedY
end

return Player