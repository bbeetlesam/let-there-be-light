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
local sounds = require("src.sounds")

local theRoom = {}

function theRoom:load()
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
    self.player = Player:new(0, 0, 60, true) -- start 10, 0 -- speed 60
    -- self.player = Player:new(1100, 300, 250, true) -- start 10, 0 -- speed 60
    self.player:setHardLimits(8, 50000, -50000, 50000) -- useless param besides 8 lol

    self.camera = Camera:new(-15, -5, 1)

    -- maingame's texts
    self.text = Font:new({"assets/img/sprite-font2.png", "assets/img/sprite-font1.png"}, {12, 12}, {16, 16}, 16, 6, 10)

    -- create flashlights
    self.flashlights = Flashlight:new()
    self.flashlights:add(350, -20)
    self.flashlights:add(502, 307)

    -- particles
    self.particles = utils.particle.generateParticles(5, -5, 20, 20, function(x, y)
        love.graphics.setColor(0.45, 0.4, 0.35, 0.4)
        love.graphics.points(x, y)
    end, 30)
    self.particles = utils.particle.generateParticles(2070 - 30, 290 - 10, 30, 20, function(x, y)
        love.graphics.setColor(0.45, 0.4, 0.35, 0.4)
        love.graphics.points(x, y)
    end, 30)
    utils.particle.addParticle(self.particles, 70, 45)

    -- tweens
    self.lightTween = Tween:new(0, 250, 1, function(t) -- default 3 secs
        return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t -- easeInOutQuad
    end)

    self.beerImage = love.graphics.newImage("assets/img/beer.png")
    self.floorImage = love.graphics.newImage("assets/img/floor.png")
    self.wallImage = love.graphics.newImage("assets/img/wall.png")
    self.floors = {}
    self.walls = {}

    -- add walls and floors
    local floorSize = self.floorImage:getWidth() * 0.6
    for i = 0, 25 - 1 do
        local startX, startY = 5, -40 -- lurus dari pintu
        table.insert(self.walls, {x = startX + i*floorSize, y = startY, w = floorSize/self.wallImage:getWidth()})
        for j = 0, 5 - 1 do
            table.insert(self.floors, {x = startX + floorSize*i, y = startY + floorSize*j})
        end
    end
    for i = 0, 5 - 1 do
        local startX, startY = 5 + 25*floorSize, -40 -- cabang pertama keatas (deadend)
        for j = 0, 20 - 1 do
            table.insert(self.floors, {x = startX + floorSize*i, y = startY + floorSize*j})
        end
    end
    for i = 0, 5 - 1 do
        local startX, startY = 5 + 25*floorSize, - 40 - 24*floorSize -- cabang kedua kebawah (alur)
        for j = 0, 24 - 1 do
            table.insert(self.floors, {x = startX + floorSize*i, y = startY + floorSize*j})
        end
    end
    for i = 0, 30 - 1 do
        local startX, startY = 5 + 25*floorSize + 5*floorSize, -40 + 15*floorSize -- cabang kedua lurus
        for j = 0, 5 - 1 do
            table.insert(self.floors, {x = startX + floorSize*i, y = startY + floorSize*j})
        end
    end
    for i = 0, 5 - 1 do
        local startX, startY = 5 + 42*floorSize, -40 -- cabang pertama bawah (deadend)
        for j = 0, 15 - 1 do
            table.insert(self.floors, {x = startX + floorSize*i, y = startY + floorSize*j})
        end
    end
    for i = 0, 35 - 1 do
        local startX, startY = 5 + 60*floorSize, -40 + floorSize*15 -- main room
        for j = 0, 5 - 1 do
            table.insert(self.floors, {x = startX + floorSize*i, y = startY + floorSize*j})
        end
    end
    for i = 0, 12 - 1 do
        local startX, startY = 5 + 95*floorSize, -40 + floorSize*15 -- after main room
        for j = 0, 5 - 1 do
            table.insert(self.floors, {x = startX + floorSize*i, y = startY + floorSize*j})
        end
    end

    -- interactable stuffs
    self.interactables = Interactables:new()
    self.interactables:add("door-first", 0, 0, 20, love.graphics.newImage("assets/img/door.png"), nil, "while", {0, 1.1, 1.5}, nil, true)
    self.interactables:add("beer", 530, -480, 20, love.graphics.newImage("assets/img/beer.png"), nil, "while", {-1, 0.5, 0.5}, nil, true)
    self.interactables:add("wardrobe", 860, -35, 25, love.graphics.newImage("assets/img/wardrobe-closed.png"), nil, "while", {0, 1.1, 1.2}, nil, true)
    self.interactables:add("door2", 918, 100, 25, love.graphics.newImage("assets/img/door.png"), nil, "while", {0, 1.1, 1.2}, nil, true)
    self.interactables:add("door3", 801, 100, 25, love.graphics.newImage("assets/img/door.png"), nil, "while", {0, -1.1, 1.2}, nil, true)
    self.interactables:add("door-finish", 2070, 290, 25, love.graphics.newImage("assets/img/door.png"), nil, "while", {0, -1.1, 1.2}, nil, true)

    -- add random beers
    for i = 1, 25 do
        local x, y

        x = 5 + 65*floorSize + floorSize*math.floor(math.random(0, 30))
        y = -40 + floorSize*15 + floorSize*math.floor(math.random(0, 4)) - 3
        local r = math.random(-0.7, 0.3)

        local name = "beer-living-" .. i
        self.interactables:add(name, x, y, 5.5, self.beerImage, nil, "while", {r, 0.4, 0.4, 0, 12}, nil, true)
    end

    -- player's blocking squares
    self.player:addBlockingSquare(5, -40 + self.floorImage:getHeight()*5*0.6, self.floorImage:getWidth()*0.6*25, floorSize*15) -- bawah pertama
    self.player:addBlockingSquare(5, -40 - floorSize*24, floorSize*25, floorSize*24) -- atas pertama
    self.player:addBlockingSquare(5 + floorSize*25, -40 - floorSize*24 - 100, floorSize*5, 100) -- deadend pertama
    self.player:addBlockingSquare(5 + floorSize*30, -40 - floorSize*24, floorSize*12, floorSize*(24 + 15))
    self.player:addBlockingSquare(5 + floorSize*42, -40 - 100, floorSize*5, 100) -- deadend kedua
    self.player:addBlockingSquare(5 + floorSize*47, -40 - floorSize*24, floorSize*13, floorSize*(24 + 15))
    self.player:addBlockingSquare(5 + floorSize*25, -40 + floorSize*20, floorSize*(70 + 12), floorSize*8) -- bawah kedua
    self.player:addBlockingSquare(5 + floorSize*95, -40 + floorSize*15 - floorSize*5, floorSize*12, floorSize*5) -- atas ketiga
    self.player:addBlockingSquare(5 + floorSize*60, -40 + floorSize*15 - 98, floorSize*(35), 100) -- main room
end

function theRoom:update(dt)
    self.time = self.time + dt
    self.timer = self.timer + dt
    self.player:update(dt)
    self.player:setPlayable(self.playable)
    local x, y = self.player:getPosition()

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

    -- set light's radius and states
    _, self.flashlightDist = self.flashlights:getClosest(x, y)
    local flashlightDist = self.flashlightDist
    if self.state == -1 then
        self.lightRadius = self.lightTween.value
    elseif self.state == 0 then
        local minDist, maxDist = 25, 150
        local t = utils.clamp((flashlightDist - minDist) / (maxDist - minDist), 0, 1)
        self.lightRadius = (1 - t) * 1400 + t * 250
    elseif self.state == 1 then
        sounds.shepard:play()
        sounds.shepard:setVolume(0.25)
        self.camTween:update(dt)
        self.camera:setZoom(self.camTween.value)
        if self.timer > 9.75 then -- 9.75 for first delay
            self.lightRadius = math.max(0, self.lightRadius - dt * 65)
            self.playable = true

            local dist = math.abs(y - 230)
            local intensity = math.min(5, 75 / dist)
            self.shakeX = love.math.random(-intensity, intensity)
            self.shakeY = love.math.random(-intensity, intensity)
        end

        if self.lightRadius < 5 then
            sounds.shepard:stop()
            self.timer = 0
            self.state = 2
        end

        -- if hit beers
        if self.interactableId and self.interactableId:sub(1, #"beer-living") == "beer-living" then
            sounds.beerClang:play()
            sounds.beerClang:setVolume(0.5)
            self.timer = 0
            self.state = 2
            self.beerHit = true
            sounds.shepard:stop()
        end

        if x >= 1840 then
            self.lightRadiusPrev = self.lightRadius
            self.camTweenL = Tween:new(1.5, 1, 2, function(t)
                return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t -- easeInOutQuad
            end)
            self.lightTweenL = Tween:new(self.lightRadiusPrev, 450, 1.5, function(t)
                return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t -- easeInOutQuad
            end)
            local floorSize = self.floorImage:getWidth() * 0.6
            self.player:addBlockingSquare(5 + 95*floorSize - 100, -40 + floorSize*15, 100, floorSize*5)
            self.player:addBlockingSquare(5 + 107*floorSize, -40 + floorSize*15, 100, floorSize*5)
            sounds.shepard:stop()
            self.state = 3
        end
    elseif self.state == 2 then -- lose/caught
        self.playable = false

        if self.beerHit then
            if self.timer > 1 then
                self.lightRadius = 0
            end

            if self.timer > 8 then
                require("src.scenes.sceneManager"):load("loseCaught")
            end
        else
            self.lightRadius = 0
            if self.timer > 2 then
                sounds.crying:play()
                sounds.crying:setVolume(1)
            end
            if self.timer > 6 then
                require("src.scenes.sceneManager"):load("loseCaught")
            end
        end
    elseif self.state == 3 then -- win
        self.player:setSpeed(40)
        self.camTweenL:update(dt)
        self.lightTweenL:update(dt)
        self.camera:setZoom(self.camTweenL.value)
        self.lightRadius = self.lightTweenL.value
        if self.win then
            self.playable = false
            if self.timer > 3 then
                self.lightRadius = 0
            end
            if self.timer > 6 then
                require("src.scenes.sceneManager"):load("win")
            end
        end
    end

    -- going in main room
    if self.state == 0 and x >= 1170 then
        local floorSize = self.floorImage:getWidth() * 0.6
        self.player:addBlockingSquare(5 + floorSize*60 - 100, -40 + floorSize*15, 100, floorSize*5)
        self.player:setSpeed(25)
        self.timer = 0
        self.camTween = Tween:new(1, 1.5, 1.5, function(t)
            return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t -- easeInOutQuad
        end)
        self.playable = false
        self.state = 1
    end
end

function theRoom:draw()
    self.canvas:with("maingame", function()
        -- background color
        love.graphics.setColor(love.math.colorFromBytes(5, 5, 5))
        love.graphics.rectangle("fill", 0, 0, const.GAME_WIDTH, const.GAME_HEIGHT)

        self.camera:attach()
            for _, floor in ipairs(self.floors) do
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(self.floorImage, floor.x, floor.y, 0, 0.6)
            end
            -- self.player:drawBlockingSquares()

            utils.particle.drawParticles(self.particles)
            self.interactables:draw()
            self.flashlights:drawAll()
            self.player:draw()

            local floorSize = self.floorImage:getWidth() * 0.6
            for i = 0, 35 - 1 do
                local startX, startY = 5 + 60*floorSize, -40 + floorSize*10 -- main room
                for j = 0, 5 - 1 do
                    table.insert(self.floors, {x = startX + floorSize*i, y = startY + floorSize*j})
                end
            end

        self.camera:detach()
    end)

    love.graphics.setShader(shaders.light)
    self.canvas:drawAll(self.shakeX, self.shakeY)
    love.graphics.setShader()

    -- interactable stuffs
    if self.interact and not self.doorScene and not self.win then
        if self.interactableId == "wardrobe" then
            self.text:print("Don't hide.", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
        elseif self.interactableId == "beer" then
            self.text:print("Papa's favorite drink.", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
        elseif self.interactableId == "door2" then
            self.text:print("Monster's room.", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
        elseif self.interactableId == "door3" then
            self.text:print("I don't know.", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
        elseif self.interactableId == "door-finish" then
            self.text:print("[Press ENTER to interact]", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
        end
    end

    -- texts and dialogues
    if self.player:willHitLimit() and self.interactableId == "door-first" then
        self.text:print("Don't go back.", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
    end

    if self.state == 1 then
        if utils.isValueAround(self.timer, 0.5, 4) then
            self.text:print("\"I'm scared...\"", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
        end
        if utils.isValueAround(self.timer, 5, 8.5) then
            self.text:print("Face it.", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
        end
        if utils.isValueAround(self.timer, 9.5, 13) then
            self.text:print("[Press ENTER to encourage Maro.]", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
        end
    end

    if self.state == 2 then
        if self.beerHit then
            if utils.isValueAround(self.timer, 2, 6) then
                love.graphics.setColor(1, 0, 0)
                self.text:print("WHERE YOU GOIN YOU LITTLE PIECE OF SHIT", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2.7, 0.5, 0.5)
            end
        end
    end

    -- debugging infos
    -- local x, y = self.player:getPosition()
    -- love.graphics.setColor(1, 1, 1)
    -- love.graphics.print("X: " .. x .. "\nY: " .. y, 10, 10)
    -- love.graphics.print("state: " .. self.state, 10, 50)
    -- love.graphics.print("id: " .. (self.interactableId or "nil"), 10, 70)
    -- love.graphics.print("time: " .. self.time .. "\ntimer: " .. self.timer, 10, 100)
    -- love.graphics.print("light: " .. self.lightRadius, 10, 140)
    -- love.graphics.print(math.abs(y - 230), 10, 160)
end

function theRoom:keypressed(key)
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

        if self.state == 1 then
            self.lightRadius = math.min(self.lightRadius + 9, 400)
        end

        if self.state == 3 and self.interactableId == "door-finish" and not self.win then
            sounds.doorOpen:play()
            sounds.doorOpen:setVolume(1)
            self.timer = 0
            self.win = true
        end
    end
end

return theRoom