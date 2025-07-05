local const = require("src.const")
local utils = require("src.utils")
local Font = require("src.font")
local Rect = require("src.rectangles")

local opening = {}

function opening:load()
    self.time = 0
    self.askTime = 0
    self.asking = false
    self.diffTime = 0

    self.text = Font:new({"assets/img/sprite-font2.png", "assets/img/sprite-font1.png"}, {12, 12}, {16, 16}, 16, 6, 10)

    self.rectImage = love.graphics.newImage("assets/img/sprite-rectangle.png")
    Rect.initRects("rect", self.rectImage)
end

function opening:update(dt)
    self.time = self.time + dt
    self.diffTime = self.time - self.askTime

    if utils.isValueAround(self.time, 7.5, 7.6) then
        self.asking = true
    end

    if self.asking then
        self.askTime = self.askTime + dt
    end

    if utils.isValueAround(self.diffTime, 15, 15.1) then
        require("src.scenes.sceneManager"):load("maingame")
    end

    self.text:update(dt)
end

function opening:draw()
    if utils.isValueAround(self.diffTime, 0, 3) then
        self.text:print("Where am I?", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
    elseif utils.isValueAround(self.diffTime, 3.5, 6.5) then
        self.text:print("This is darker than usual...", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
    end

    if self.asking then
        self.text:print("Do you believe there's still courage", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*2/5, 3, 0.5, 0.5)
        self.text:print("left in you?", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*2/5 + 60, 3, 0.5, 0.5)

        local sizeA = love.keyboard.isDown("a") and {375, 125} or {350, 100}
        local sizeD = love.keyboard.isDown("d") and {375, 125} or {350, 100}

        Rect.draw("rect", self.rectImage, const.SCREEN_WIDTH*4/12, const.SCREEN_HEIGHT*3/5, sizeA[1], sizeA[2], 0.5, 0.5)
        Rect.draw("rect", self.rectImage, const.SCREEN_WIDTH*8/12, const.SCREEN_HEIGHT*3/5, sizeD[1], sizeD[2], 0.5, 0.5)

        love.graphics.setColor(0, 0, 0)
        self.text:print("Yes", const.SCREEN_WIDTH*8/12, const.SCREEN_HEIGHT*3/5, 3, 0.5, 0.5)
        self.text:print("No", const.SCREEN_WIDTH*4/12, const.SCREEN_HEIGHT*3/5, 3, 0.5, 0.5)
        self.text:print("D", const.SCREEN_WIDTH*8/12 + 350/2 - 12, const.SCREEN_HEIGHT*3/5 + 100/2 - 5, 1.6, 1, 1)
        self.text:print("A", const.SCREEN_WIDTH*4/12 + 350/2 - 12, const.SCREEN_HEIGHT*3/5 + 100/2 - 5, 1.6, 1, 1)
        love.graphics.setColor(1, 1, 1)
    end

    if utils.isValueAround(self.diffTime, 9, 13.5) then
        if self.answer == "yes" then
            self.text:print("I hope so.", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT/2, 3, 0.5, 0.5)
        elseif self.answer == "no" then
            self.text:print("What a pity.", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT/2, 3, 0.5, 0.5)
        end
    end
end

function opening:keypressed(key)
    if self.asking then
        if key == "a" then
            self.answer = "no"
            self.asking = false
        elseif key == "d" then
            self.answer = "yes"
            self.asking = false
        end
    end
end

return opening