local const = require("src.const")
local Font = require("src.font")
local sounds = require("src.sounds")

local intro = {}

function intro:load()
    self.time = 0
    self.timer = 0

    self.title = Font:new({"assets/img/sprite-font2.png", "assets/img/sprite-font1.png"}, {12, 12}, {16, 16}, 16, 6, 10)
    self.transitioning = false
    sounds.tvTalking:play()
    sounds.tvTalking:setVolume(0.7)
end

function intro:update(dt)
    self.time = self.time + dt
    self.title:update(dt)

    if self.transitioning then
        self.timer = self.timer + dt

        if self.timer > 2 then
            require("src.scenes.sceneManager"):load("opening")
        end
    end
end

function intro:draw()
    love.graphics.setColor(1, 1, 1)

    if not self.transitioning then
        self.title:print("Let There be Light", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT/2, 4.5, 0.5, 0.5)
        self.title:print("_Press any key to begin_", const.SCREEN_WIDTH/2, const.SCREEN_HEIGHT*5/8, 1.6, 0.5, 0.5)
    end
end

function intro:keypressed(key)
    sounds.tvTalking:stop()
    self.transitioning = true
end

return intro