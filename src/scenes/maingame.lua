local const = require("src.const")
local utils = require("src.utils")
local shaders = require("src.shaders.shaders")
local Font = require("src.font")
local Player = require("src.player")
local Camera = require("src.camera")
local CanvasManager = require("src.canvasManager")
local Tween = require("src.tween")

local maingame = {}

function maingame:load()
    self.time = 0
    self.playable = false
    self.boundary = {x = 0, y = 0, w = 400, h = 400}
    self.playerInside = true

    -- create maingame's canvas
    self.canvas = CanvasManager:new()
    self.canvas:create("maingame", const.GAME_WIDTH, const.GAME_HEIGHT, const.SCALE_FACTOR, {"nearest", "nearest"})

    self.lightRadius = 0
    self.lightTween = Tween:new(0, 275, 2.5, function(t)
        return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t -- easeInOutQuad
    end)

    self.player = Player:new(0, 0, 60, false)
    self.camera = Camera:new(0, 0, 1)

    self.player:setBoundary(self.boundary.x, self.boundary.y, self.boundary.w, self.boundary.h)

    -- maingame's texts
    self.text = Font:new({"assets/img/sprite-font2.png", "assets/img/sprite-font1.png"}, {12, 12}, {16, 16}, 16, 6, 10)

    -- (0,0) point particles
    self.firstParticles = utils.particle.generateParticles(0 - 20/2, 0 - 20/2, 20, 20, function(x, y)
        love.graphics.setColor(0.45, 0.4, 0.35, 0.4)
        love.graphics.points(x, y)
    end, 15)
end

function maingame:update(dt)
    self.time = self.time + dt
    self.player:update(dt)

    -- light shader
    self.lightTween:update(dt)
    self.lightRadius = self.lightTween.value
    local a, b = utils.screenToWorld(const.GAME_WIDTH/2, const.GAME_HEIGHT/2 - 10)
    shaders.light:send("lightPos", {a, b})
    shaders.light:send("radius", self.lightRadius)

    -- set camera to player's pos
    local x, y = self.player:getPosition()
    self.camera:setPosition(x, y)

    -- update texts
    self.text:update(dt)

    -- set player playable after tweening is done
    if self.lightTween:isFinished() then
        self.playable = true
        self.player:setPlayable(true)
    end
end

function maingame:draw()
    self.canvas:with("maingame", function()
        -- background color
        love.graphics.setColor(love.math.colorFromBytes(17, 17, 17))
        love.graphics.rectangle("fill", 0, 0, const.GAME_WIDTH, const.GAME_HEIGHT)

        self.camera:attach()
            utils.particle.drawParticles(self.firstParticles)
            self.player:draw()
        self.camera:detach()
    end)

    love.graphics.setShader(shaders.light)
    self.canvas:drawAll()
    love.graphics.setShader()

    -- narrator's comments
    if utils.isValueAround(self.time, 2.75, 6) then
        self.text:print("He needs to find out.", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
    end

    if self.player:isClamped() then
        self.text:print("[He's too afraid to go further.]", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
    end

    -- debugging infos
    local x, y = self.player:getPosition()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("X: " .. x .. "\nY: " .. y, 10, 10)
    love.graphics.print("Light: " .. self.lightTween.value, 10, 50)
    love.graphics.print("player clamped: " .. tostring(self.player:isClamped()), 10, 70)
end

function maingame:keypressed(key)
    
end

return maingame