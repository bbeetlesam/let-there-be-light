local const = require("src.const")
local utils = require("src.utils")
local sounds = require("src.sounds")
local Font = require("src.font")

local win = {}

function win:load()
    self.time = 0
    self.timer = 0
    self.text = Font:new({"assets/img/sprite-font2.png", "assets/img/sprite-font1.png"}, {12, 12}, {16, 16}, 16, 6, 10)
end

function win:update(dt)
    self.time = self.time + dt
    self.timer = self.timer + dt

    self.text:update(dt)
end

function win:draw()
    if utils.isValueAround(self.timer, 1, 4) then
    self.text:print("So... did you do it, Maro?", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
    end
    if utils.isValueAround(self.timer, 4.5, 8.5) then
        self.text:print("\"I think I did...\"", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
    end
    if utils.isValueAround(self.timer, 9, 13.5) then
        self.text:print("But you're still here, aren't you?", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
    end
    if utils.isValueAround(self.timer, 14, 18.5) then
        self.text:print("\"...Yeah. I never left my bed, did I?\"", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
    end
    if utils.isValueAround(self.timer, 19, 23.5) then
        self.text:print("No. But at least... you tried to.", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
    end
    if utils.isValueAround(self.timer, 24, 28) then
        self.text:print("\"...In my head\"", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
    end

    if self.timer > 29.5 then
        require("src.scenes.sceneManager"):load("intro")
    end
end

function win:keypressed(key)
    local ENTER = (key == "return")
end

return win