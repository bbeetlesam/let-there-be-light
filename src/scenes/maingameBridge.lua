local const = require("src.const")
-- local utils = require("src.utils")
local Font = require("src.font")
local Rect = require("src.rectangles")
-- local Tween = require("src.tween")

local maingameBridge = {}

function maingameBridge:load()
    self.time = 0
    self.timer = 0
    self.textIndex = 10
    self.choosing = false
    self.answer = nil

    self.text = Font:new({"assets/img/sprite-font2.png", "assets/img/sprite-font1.png"}, {12, 12}, {16, 16}, 16, 6, 10)
    self.textString = {
        "Here he lies again in his only warm bed",
        "\"...It's warm here. I feel safe.\"",
        "But you said this place feels like a prison.",
        "\"Yeah... but at least I know where the monsters are.\"",
        "So you'd rather stay in the dark you already know?",
        "\"I tried once. I stepped out, and he found me.\"",
        "And yet, you came this far. You found the light.",
        "...But the light doesn't hide me. He'll see me if I go.",
        "\"He already sees you. Every night. Every time you close your eyes.\"",
        "\"So what now, little one? Stay and wait... or try and run?\"",

        "So be it.",
        "Not every bird learns to fly.",

        "Then let's find out what's beyond the dark.",
        "Step gently, Maro.",
        "The night remembers everything."
    }

    self.rectImage = love.graphics.newImage("assets/img/sprite-rectangle.png")
    Rect.initRects("rect", self.rectImage)
end

function maingameBridge:update(dt)
    self.time = self.time + dt
    self.timer = self.timer + dt

    self.text:update(dt)
end

function maingameBridge:draw()
    if self.answer == nil then
        if not self.choosing then
            self.text:print(self.textString[self.textIndex], const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
        else
            local sizeA = love.keyboard.isDown("a") and {375, 125} or {350, 100}
            local sizeD = love.keyboard.isDown("d") and {375, 125} or {350, 100}

            self.text:print("Stay or Try?", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*3/8, 4, 0.5, 0.5)
            Rect.draw("rect", self.rectImage, const.SCREEN_WIDTH*4/12, const.SCREEN_HEIGHT*4/7, sizeA[1], sizeA[2], 0.5, 0.5)
            Rect.draw("rect", self.rectImage, const.SCREEN_WIDTH*8/12, const.SCREEN_HEIGHT*4/7, sizeD[1], sizeD[2], 0.5, 0.5)

            love.graphics.setColor(0, 0, 0)
            self.text:print("Try", const.SCREEN_WIDTH*8/12, const.SCREEN_HEIGHT*4/7, 3, 0.5, 0.5)
            self.text:print("Stay", const.SCREEN_WIDTH*4/12, const.SCREEN_HEIGHT*4/7, 3, 0.5, 0.5)
            self.text:print("D", const.SCREEN_WIDTH*8/12 + 350/2 - 12, const.SCREEN_HEIGHT*4/7 + 100/2 - 5, 1.6, 1, 1)
            self.text:print("A", const.SCREEN_WIDTH*4/12 + 350/2 - 12, const.SCREEN_HEIGHT*4/7 + 100/2 - 5, 1.6, 1, 1)
            love.graphics.setColor(1, 1, 1)
        end
    else
        if self.textIndex == 12 then
            if self.answer == "try" then
                self.text:print(self.textString[self.textIndex + self.answerId], const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*5/12, 3.5, 0.5, 0.5)
                self.text:print(self.textString[self.textIndex + self.answerId + 1], const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*7/12, 3.5, 0.5, 0.5)
            else
                self.text:print(self.textString[self.textIndex + self.answerId], const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT/2, 3.5, 0.5, 0.5)
            end
        else
            self.text:print(self.textString[self.textIndex + self.answerId], const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
        end
    end

    -- debugging infos
    -- love.graphics.setColor(1, 1, 1)
    -- love.graphics.print("time: " ..self.time, 10, 10)
    -- love.graphics.print("timer: " ..self.timer, 10, 30)
    -- love.graphics.print("id: " ..self.textIndex, 10, 50)
    -- love.graphics.print("choosing: " ..tostring(self.choosing), 10, 70)
    -- love.graphics.print("answer: " .. (self.answer or "nil"), 10, 90)
end

function maingameBridge:keypressed(key)
    local ENTER = (key == "return")

    if self.choosing then
        if key == "a" then
            self.answer = "stay"
            self.answerId = 0
            self.timer = 0
            self.textIndex = self.textIndex + 1
            self.choosing = false
        elseif key == "d" then
            self.answer = "try"
            self.answerId = 2
            self.timer = 0
            self.textIndex = self.textIndex + 1
            self.choosing = false
        end
        return
    else
        if ENTER then
            if self.timer > 1.5 and not self.choosing then
                if self.textIndex == 12 and self.answer == "stay" then
                    require("src.scenes.sceneManager"):load("intro")
                    return
                end
                if self.textIndex == 12 and self.answer == "try" then
                    require("src.scenes.sceneManager"):load("maingame2")
                    return
                end

                if self.textIndex + 1 == 11 then
                    self.choosing = true
                    self.timer = 0
                    return
                end

                self.textIndex = self.textIndex + 1
                self.timer = 0
            end
        end
    end
end

return maingameBridge