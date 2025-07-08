local const = require("src.const")
local utils = require("src.utils")
local sounds = require("src.sounds")
local Font = require("src.font")

local loseCaught = {}

function loseCaught:load()
    self.time = 0
    self.timer = 0
    self.text = Font:new({"assets/img/sprite-font2.png", "assets/img/sprite-font1.png"}, {12, 12}, {16, 16}, 16, 6, 10)
end

function loseCaught:update(dt)
    self.time = self.time + dt
    self.timer = self.timer + dt

    self.text:update(dt)
end

function loseCaught:draw()
    if self.timer > 0 then
        self.text:print("Walk slowly, Maro.", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT/2, 4, 0.5, 0.5)
    end
    if self.timer > 2 then
        self.text:print("ENTER to try again.", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*9/10, 2, 0.5, 0.5)
    end
end

function loseCaught:keypressed(key)
    local ENTER = (key == "return")

    if ENTER and self.timer > 3 then
        sounds.crying:stop()
        require("src.scenes.sceneManager"):load("theRoom")
    end
end

return loseCaught