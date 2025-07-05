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

function Player:new(x, y)
    local self = setmetatable({}, Player)
    self.x = x or 0
    self.y = y or 0
    self.speed = 60
    return self
end

function Player:update(dt)
    local dx, dy = 0, 0

    -- character's movement
    local left  = love.keyboard.isDown("a")
    local right = love.keyboard.isDown("d")
    local up = love.keyboard.isDown("w")
    local down = love.keyboard.isDown("s")

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

    self.x = self.x + dx * self.speed * dt
    self.y = self.y + dy * self.speed * dt

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

return Player