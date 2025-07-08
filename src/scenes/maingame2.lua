local const = require("src.const")
local utils = require("src.utils")
local shaders = require("src.shaders.shaders")
local Font = require("src.font")
local Player = require("src.player")
local Camera = require("src.camera")
local CanvasManager = require("src.canvasManager")
local Tween = require("src.tween")
local Flashlight = require("src.flashlight")
local Interactables = require("src.interactables")

local maingame2 = {}

function maingame2:load()
    self.time = 0
    self.timer = 0
    self.lightRadius = 0
    self.playable = false
    self.state = -1
    self.doorScene = false

    -- create maingame's canvas
    self.canvas = CanvasManager:new()
    self.canvas:create("maingame", const.GAME_WIDTH, const.GAME_HEIGHT, const.SCALE_FACTOR, {"nearest", "nearest"})

    -- create player
    self.player = Player:new(-15, -5, 60, true) -- start -15, -5 -- speed 60
    self.player:setHardLimits(-600, 550, -700, 750)
    self.camera = Camera:new(-15, -5, 1)

    -- maingame's texts
    self.text = Font:new({"assets/img/sprite-font2.png", "assets/img/sprite-font1.png"}, {12, 12}, {16, 16}, 16, 6, 10)

    -- interactable stuffs
    self.interactables = Interactables:new()
    self.interactables:add("bed", 0, 0, 10, love.graphics.newImage("assets/img/maro-bed.png"), nil, "while", {-0.1, 1.75, 1.55}, nil, true)
    self.interactables:add("wardrobe", 125, 390, 25, love.graphics.newImage("assets/img/wardrobe-opened.png"), nil, "while", {0, 1.1, 1.2}, nil, true)
    self.interactables:add("door", 550, 700, 20, love.graphics.newImage("assets/img/door.png"), nil, "while", {0, 1.1, 1.5}, nil, true)

    -- create flashlights
    self.flashlights = Flashlight:new()
    self.flashlights:add(135, 90)
    self.flashlights:add(420, 690)

    -- particles
    self.particles = utils.particle.generateParticles(0 - 30/2, 0 - 30/2, 30, 30, function(x, y)
        love.graphics.setColor(0.45, 0.4, 0.35, 0.4)
        love.graphics.points(x, y)
    end, 30)
    utils.particle.addParticle(self.particles, 70, 45)
    utils.particle.addParticle(self.particles, 150, 190)
    utils.particle.addParticle(self.particles, 180, 260)
    utils.particle.addParticle(self.particles, 210, 310)
    utils.particle.addParticle(self.particles, 200, 355)
    utils.particle.addParticle(self.particles, 185, 430)
    utils.particle.addParticle(self.particles, 230, 440)
    utils.particle.addParticle(self.particles, 270, 420)
    utils.particle.addParticle(self.particles, 300, 460)
    utils.particle.addParticle(self.particles, 330, 510)

    -- tweens
    self.lightTween = Tween:new(0, 250, 3, function(t) -- default 3 secs
        return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t -- easeInOutQuad
    end)
    self.camTween = Tween:new(1, 1.75, 2.5, function(t)
        return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t -- easeInOutQuad
    end)
end

function maingame2:update(dt)
    self.time = self.time + dt
    self.timer = self.timer + dt
    self.player:update(dt)
    self.player:setPlayable(self.playable)
    local x, y = self.player:getPosition()
    self.playerPos = {x = x, y = y}

    -- set camera to player's pos
    self.camera:setPosition(x, y)

    -- update texts
    self.text:update(dt)

    local a, b = utils.screenToWorld(const.GAME_WIDTH/2, const.GAME_HEIGHT/2 - 10)
    shaders.light:send("lightPos", {a, b})
    shaders.light:send("radius", self.lightRadius)

    -- update interactables
    self.interactables:update(x, y)
    self.interactableId, _ = self.interactables:getClosest(x, y)
    if self.interactableId then self.interact = true else self.interact = false end

    -- tweens updates
    if self.timer > 1 then -- 1 for first delay
        self.lightTween:update(dt)
    end
    self.lightTween:onFinish(function()
        self.playable = true
        self.state = 0
    end)

    -- set light's radius
    _, self.flashlightDist = self.flashlights:getClosest(x, y)
    local flashlightDist = self.flashlightDist
    if self.state == -1 then
        self.lightRadius = self.lightTween.value
    elseif self.state == 0 then
        local minDist, maxDist = 25, 150
        local t = utils.clamp((flashlightDist - minDist) / (maxDist - minDist), 0, 1)
        self.lightRadius = (1 - t) * 1400 + t * 250
    elseif self.state == 1 then
        self.lightRadius = self.lightTweenLast.value
    end

    -- go out fromm door scene
    if self.doorScene then
        self.playable = false
        self.camTween:update(dt)
        self.camera:setZoom(self.camTween.value)

        if self.timer > 9 then
            self.lightTweenLast:update(dt)
        end
        self.lightTweenLast:onFinish(function()
            require("src.scenes.sceneManager"):load("theRoom")
        end)
    end
end

function maingame2:draw()
    self.canvas:with("maingame", function()
        -- background color
        love.graphics.setColor(love.math.colorFromBytes(17, 17, 17))
        love.graphics.rectangle("fill", 0, 0, const.GAME_WIDTH, const.GAME_HEIGHT)

        self.camera:attach()
            utils.particle.drawParticles(self.particles)
            self.interactables:draw()
            self.flashlights:drawAll()
            self.player:draw()
        self.camera:detach()
    end)

    love.graphics.setShader(shaders.light)
    self.canvas:drawAll()
    love.graphics.setShader()

    -- interactable stuffs
    if self.interact and not self.doorScene then
        if self.interactableId == "wardrobe" then
            self.text:print("[Maro's timeout closet.]", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
        elseif self.interactableId == "bed" then
            self.text:print("[Maro's hiding blanket.]", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
        elseif self.interactableId == "door" then
            self.text:print("[Press ENTER to go]", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
        end
    end

    -- texts and dialogues
    if self.player:willHitLimit() and not self.interact then
        self.text:print("Don't you want to go out?", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
    end

    if self.doorScene then
        if utils.isValueAround(self.timer, 1, 4) then
            self.text:print("Take a deep breath, Maro.", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
        end
        if utils.isValueAround(self.timer, 4.5, 8.5) then
            self.text:print("This time might be your chance.", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
        end
    end

    -- debugging infos
    -- local x, y = self.player:getPosition()
    -- love.graphics.setColor(1, 1, 1)
    -- love.graphics.print("X: " .. x .. "\nY: " .. y, 10, 10)
    -- love.graphics.print("state: " .. self.state, 10, 50)
    -- love.graphics.print("id: " .. (self.interactableId or "nil"), 10, 70)
    -- love.graphics.print("time: " .. self.time .. "\ntimer: " .. self.timer, 10, 100)
end

function maingame2:keypressed(key)
    local ENTER = (key == "return")

    if ENTER then
        if self.interact and self.interactableId == "door" and not self.doorScene then
            self.doorScene = true
            self.timer = 0
            self.state = 1
            self.lightRadiusPrev = self.lightRadius

            self.lightTweenLast = Tween:new(self.lightRadiusPrev, 0, 3, function(t)
                return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t -- easeInOutQuad
            end)
        end
    end
end

return maingame2