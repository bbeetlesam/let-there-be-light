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

local maingame = {}

function maingame:load()
    self.time = 0
    self.timer = 0
    self.playable = false
    self.boundary = {x = 0, y = 0, w = 400, h = 400}
    self.boundary = {x = nil, y = nil, w = nil, h = nil}
    self.state = -1 -- start -1
    self.interactShow = false
    self.interact = false
    self.hasInteracted = {}
    self.flashlightDist = 0
    self.transitionTo2 = false

    -- create maingame's canvas
    self.canvas = CanvasManager:new()
    self.canvas:create("maingame", const.GAME_WIDTH, const.GAME_HEIGHT, const.SCALE_FACTOR, {"nearest", "nearest"})

    -- first tween
    self.lightRadius = 0 -- default 0
    self.prevLightRadius = 0
    self.lightTween = Tween:new(0, 250, 2.5, function(t)
        return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t -- easeInOutQuad
    end)

    self.player = Player:new(0, 0, 60, false) -- start 0, 0 -- speed 60
    self.camera = Camera:new(0, 0, 1)

    self.player:setBoundary(self.boundary.x, self.boundary.y, self.boundary.w, self.boundary.h)

    -- maingame's texts
    self.text = Font:new({"assets/img/sprite-font2.png", "assets/img/sprite-font1.png"}, {12, 12}, {16, 16}, 16, 6, 10)

    -- interactable stuffs
    self.interactables = Interactables:new()
    self.interactables:add("drawing", -125, -940, 10, love.graphics.newImage("assets/img/maro-drawing.png"), nil, "while", {-0.4, 0.2, 0.2}, nil, true)
    self.interactables:add("wardrobe", 200, -1050, 30, love.graphics.newImage("assets/img/wardrobe-closed.png"), nil, "while", {0, 1.1, 1.2}, nil, true)
    self.interactables:add("bed", 75, -1440, 20, love.graphics.newImage("assets/img/maro-bed.png"), nil, "while", {-0.1, 1.75, 1.55}, nil, true)
    self.hasInteracted["drawing"] = false
    self.hasInteracted["wardrobe"] = false

    -- (0,0) point particles
    self.firstParticles = utils.particle.generateParticles(0 - 20/2, 0 - 20/2, 20, 20, function(x, y)
        love.graphics.setColor(0.45, 0.4, 0.35, 0.4)
        love.graphics.points(x, y)
    end, 15)
    utils.particle.addParticle(self.firstParticles, -300, 50)
    utils.particle.addParticle(self.firstParticles, -290, -10)
    utils.particle.addParticle(self.firstParticles, -310, -80)
    utils.particle.addParticle(self.firstParticles, -320, -140)
    utils.particle.addParticle(self.firstParticles, -300, -200)

    utils.particle.addParticle(self.firstParticles, -210, -480)
    utils.particle.addParticle(self.firstParticles, -240, -540)
    utils.particle.addParticle(self.firstParticles, -200, -590)
    utils.particle.addParticle(self.firstParticles, -160, -610)
    utils.particle.addParticle(self.firstParticles, -120, -650)
    utils.particle.addParticle(self.firstParticles, -100, -690)

    -- first flashlight
    self.flashlights = Flashlight:new()
    self.flashlights:add(-169, 121) -- want it to spawn on random pos but whatever

    self.flashlights:add(-330, -420)
    self.flashlights:add(-30, -900)
    self.flashlights:add(210, -1350)
end

function maingame:update(dt)
    self.time = self.time + dt
    self.timer = self.timer + dt
    self.player:update(dt)
    self.player:setBoundary(self.boundary.x, self.boundary.y, self.boundary.w, self.boundary.h)
    self.player:setPlayable(self.playable)
    local x, y = self.player:getPosition()

    -- update interactables
    self.interactables:update(x, y)
    self.interactableId, _ = self.interactables:getClosest(x, y)
    if self.interactableId then self.interact = true else self.interact = false end
    if self.interactShow then self.interact = false end

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
        self.state = 0
    end)
    if self.state >= 0 then
        if self.interactShow then self.playable = false else self.playable = true end
    end

    -- set lightRadius
    _, self.flashlightDist = self.flashlights:getClosest(x, y)
    local flashlightDist = self.flashlightDist
    if self.state == -1 then
        self.lightRadius = self.lightTween.value
    elseif self.state == 0 then
        local minDist, maxDist = 10, 60
        local t = utils.clamp((flashlightDist - minDist) / (maxDist - minDist), 0, 1)
        self.lightRadius = (1 - t) * 1400 + t * 250
        if flashlightDist < 30 then self.state = 1 self.timer = 0 end
    elseif self.state == 1 then
        local minDist, maxDist = 25, 150
        local t = utils.clamp((flashlightDist - minDist) / (maxDist - minDist), 0, 1)
        self.lightRadius = (1 - t) * 1500 + t * 250
        self.boundary = {x = nil, y = nil, w = nil, h = nil}
    elseif self.state == 2 then
        local minDist, maxDist = 25, 150
        local t = utils.clamp((flashlightDist - minDist) / (maxDist - minDist), 0, 1)
        self.lightRadius = (1 - t) * 1500 + t * 250
        self.boundary = {x = nil, y = nil, w = nil, h = nil}
    end

    -- transition to maingame2
    if self.transitionTo2 then
        self.lightTweenLast:update(dt)
        self.lightRadius = self.lightTweenLast.value

        if self.timer > 4 then
            require("src.scenes.sceneManager"):load("maingame2")
        end
    end
end

function maingame:draw()
    self.canvas:with("maingame", function()
        -- background color
        love.graphics.setColor(love.math.colorFromBytes(17, 17, 17))
        love.graphics.rectangle("fill", 0, 0, const.GAME_WIDTH, const.GAME_HEIGHT)

        self.camera:attach()
            utils.particle.drawParticles(self.firstParticles)
            self.interactables:draw()
            self.flashlights:drawAll()
            self.player:draw()
        self.camera:detach()
    end)

    love.graphics.setShader(shaders.light)
    self.canvas:drawAll()
    love.graphics.setShader()

    -- interactable stuffs
    if self.interactShow then
        local image = self.interactables:getImage(self.interactableId)
        if self.interactableId == "drawing" then
            love.graphics.draw(image, const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT/2, -0.1, 15, nil, image:getWidth()/2, image:getHeight()/2)
            if self.hasInteracted["drawing"] then
                self.text:print("[A drawing of a happy family.]", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
            end
        elseif self.interactableId == "wardrobe" and self.hasInteracted["wardrobe"] then
            self.text:print("[Maro's bedroom wardrobe.]", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
        end
    end

    if self.transitionTo2 then return end

    -- narrator's comments (monologues)
    if self.interact then
        self.text:print("[Press ENTER to interact]", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
    end
    if self.state == 0 then
        if utils.isValueAround(self.timer, 2.75, 6) then
            self.text:print("He needs to find out.", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
        end
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
    if self.state == 2 then
        if not self.hasInteracted["drawing"] then
            if utils.isValueAround(self.timer, 0, 3) then
                self.text:print("Aw, a portrait of a happy family.", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
            end
            if utils.isValueAround(self.timer, 3.5, 6.5) then
                self.text:print("I wonder who drew it.", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
            end
            if utils.isValueAround(self.timer, 7.5, 11) then
                self.text:print("\"I dream of having a good Papa and Mama...\"", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
            end
        elseif not self.hasInteracted["wardrobe"] then
            if utils.isValueAround(self.timer, 0, 3) then
                self.text:print("You used to hide here, don't you?", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
            end
            if utils.isValueAround(self.timer, 4, 7.5) then
                self.text:print("\"Papa lock me here as a punishment...\"", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
            end
            if utils.isValueAround(self.timer, 8.5, 11.5) then
                self.text:print("No wonder you're afraid of the dark.", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
            end
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
    love.graphics.print("playable: " .. tostring(self.playable), 10, 100)
    love.graphics.print("current state: " .. self.state, 10, 120)
    love.graphics.print("interact: " .. tostring(self.interact), 10, 140)
    love.graphics.print("interact show: " .. tostring(self.interactShow), 10, 160)
    love.graphics.print("dist to fl: " .. self.flashlightDist, 10, 180)
    love.graphics.print("inter id: " .. (self.interactableId or "nil"), 10, 200)
end

function maingame:keypressed(key)
    ENTER = (key == "return" and not self.transitionTo2)

    -- if interactSHow == true, able to put it false/down/hide show
    if ENTER and self.interactShow then
        if self.state == 2 then
            if not self.hasInteracted[self.interactableId] then
                if self.timer > 12 then
                    self.interactables:enable(self.interactableId)
                    self.interactShow = false
                    self.hasInteracted[self.interactableId] = true
                end
            else
                self.interactables:enable(self.interactableId)
                self.interactShow = false
            end
        end
    end

    -- if interact == true, able to show it
    if ENTER and self.interact then
        -- bed
        if self.interactableId == "bed" then
            self.transitionTo2 = true
            self.prevLightRadius = self.lightRadius

            -- last tween before mobing to maingame2
            self.lightTweenLast = Tween:new(self.prevLightRadius, 0, 3, function(t)
                return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t -- easeInOutQuad
            end)

            self.state = 3
        end

        self.interactShow = true
        self.interactables:disable(self.interactableId)
        self.interact = false

        if not self.hasInteracted[self.interactableId] then self.timer = 0 end

        -- has interacted statuses
        if self.interactableId == "wardrobe" and self.hasInteracted["wardrobe"] then
            self.interactables:changeImage("wardrobe", love.graphics.newImage("assets/img/wardrobe-opened.png"))
        end

        -- if currently in state 1
        if self.state == 1 and self.interactableId == "drawing" then
            self.state = 2
            self.timer = 0
        end
    end
end

return maingame