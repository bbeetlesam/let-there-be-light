local const = require("src.const")
local utils = require("src.utils")
local shaders = require("src.shaders.shaders")
local Font = require("src.font")
local Player = require("src.player")
local Camera = require("src.camera")
local CanvasManager = require("src.canvasManager")
local Tween = require("src.tween")
local Flashlight = require("src.flashlight")

local maingame = {}

function maingame:load()
    self.time = 0
    self.timer = 0
    self.playable = false
    self.boundary = {x = 0, y = 0, w = 400, h = 400}
    self.state = -1
    self.flashlightDist = 0

    -- create maingame's canvas
    self.canvas = CanvasManager:new()
    self.canvas:create("maingame", const.GAME_WIDTH, const.GAME_HEIGHT, const.SCALE_FACTOR, {"nearest", "nearest"})

    self.lightRadius = 0
    self.lightTween = Tween:new(0, 250, 2.5, function(t)
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

    -- first flashlight
    self.flashlights = Flashlight:new()
    self.flashlights:add(-169, 121) -- want it to spawn on random pos but whatever
end

function maingame:update(dt)
    self.time = self.time + dt
    self.timer = self.timer + dt
    self.player:update(dt)
    local x, y = self.player:getPosition()

    -- light shader
    self.lightTween:update(dt)
    local a, b = utils.screenToWorld(const.GAME_WIDTH/2, const.GAME_HEIGHT/2 - 10)
    shaders.light:send("lightPos", {a, b})
    shaders.light:send("radius", self.lightRadius)

    -- set camera to player's pos
    self.camera:setPosition(x, y)

    -- update texts
    self.text:update(dt)

    -- set player playable after first tweening is done
    self.lightTween:onFinish(function()
        self.playable = true
        self.player:setPlayable(true)
        self.state = 0
        self.timer = 0
    end)

    -- set lightRadius
    _, self.flashlightDist = self.flashlights:getClosest(x, y)
    local flashlightDist = self.flashlightDist
    if self.state == -1 then
        self.lightRadius = self.lightTween.value
    elseif self.state == 0 then
        local minDist, maxDist = 10, 65
        local t = utils.clamp((flashlightDist - minDist) / (maxDist - minDist), 0, 1)
        self.lightRadius = (1 - t) * 1400 + t * 250
        if flashlightDist < 30 then self.state = 1 self.timer = 0 end
    elseif self.state == 1 then
        local minDist, maxDist = 20, 150
        local t = utils.clamp((flashlightDist - minDist) / (maxDist - minDist), 0, 1)
        self.lightRadius = (1 - t) * 1500 + t * 250
    end
end

function maingame:draw()
    self.canvas:with("maingame", function()
        -- background color
        love.graphics.setColor(love.math.colorFromBytes(17, 17, 17))
        love.graphics.rectangle("fill", 0, 0, const.GAME_WIDTH, const.GAME_HEIGHT)

        self.camera:attach()
            utils.particle.drawParticles(self.firstParticles)
            self.flashlights:drawAll()
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
    if self.state == 1 then
        if utils.isValueAround(self.timer, 0, 3) then
            self.text:print("Look what he found, a regular flashlight.", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
        end
        if utils.isValueAround(self.timer, 3.5, 6.5) then
            self.text:print("He feels brave when he gets nearby them.", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
        end
        if utils.isValueAround(self.timer, 7, 10) then
            self.text:print("But, he didn't dare to carry it, though.", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
        end
        if utils.isValueAround(self.timer, 11, 15) then
            self.text:print("\"I fear that Papa would kill me.\"", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
        end
    end

    -- if player is going outside boundaries
    if self.player:isClamped() then
        self.text:print("[He's too afraid to go further]", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
    end

    -- debugging infos
    local x, y = self.player:getPosition()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("X: " .. x .. "\nY: " .. y, 10, 10)
    love.graphics.print("time: " .. self.time .. "\ntimer: " .. self.timer, 10, 40)
    love.graphics.print("Light: " .. self.lightRadius, 10, 80)
    love.graphics.print("player clamped: " .. tostring(self.player:isClamped()), 10, 100)
    love.graphics.print("current state: " .. self.state, 10, 120)
    love.graphics.print("dist to fl: " .. self.flashlightDist, 10, 140)
end

function maingame:keypressed(key)
    
end

return maingame