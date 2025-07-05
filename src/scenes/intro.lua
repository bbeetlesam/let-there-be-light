local const = require("src.const")
local Font = require("src.font")

local intro = {}

function intro:load()
    self.timer = 0

    self.title = Font:new({"assets/img/sprite-font2.png", "assets/img/sprite-font1.png"}, {12, 12}, {16, 16}, 16, 6, 10)
    self.transitioning = false
end

function intro:update(dt)
    self.title:update(dt)

    if self.transitioning then
        self.timer = self.timer + dt

        if self.timer > 1.5 then
            require("src.scenes.sceneManager"):load("maingame")
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
    self.transitioning = true
end

return intro