local const = require("src.const")
local utils = require("src.utils")
local shaders = require("src.shaders.shaders")
local Font = require("src.font")
local Player = require("src.player")
local Camera = require("src.camera")
local CanvasManager = require("src.canvasManager")

local maingame = {}

function maingame:load()
    self.timer = 0

    -- create maingame's canvas
    self.canvas = CanvasManager:new()
    self.canvas:create("maingame", const.GAME_WIDTH, const.GAME_HEIGHT, const.SCALE_FACTOR, {"nearest", "nearest"})

    self.image = love.graphics.newImage("dump/octocat-1747987801490.png")
    self.lightRadius = 500

    self.player = Player:new(const.GAME_WIDTH/2, const.GAME_HEIGHT/2)
    self.camera = Camera:new(0, 0, 1)

    -- maingame's texts
    self.text = Font:new({"assets/img/sprite-font2.png", "assets/img/sprite-font1.png"}, {12, 12}, {16, 16}, 16, 6, 10)
end

function maingame:update(dt)
    self.player:update(dt)

    local x, y = self.player:getPosition()
    self.camera:setPosition(x, y)

    local a, b = utils.screenToWorld(const.GAME_WIDTH/2, const.GAME_HEIGHT/2 - 10)
    shaders.light:send("lightPos", {a, b})
    shaders.light:send("radius", self.lightRadius)

    self.text:update(dt)
end

function maingame:draw()
    self.canvas:with("maingame", function()
        love.graphics.setColor(love.math.colorFromBytes(17, 17, 17))
        love.graphics.rectangle("fill", 0, 0, const.GAME_WIDTH, const.GAME_HEIGHT)

        self.camera:attach()
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(self.image, const.GAME_WIDTH/2, const.GAME_HEIGHT/2, 0, 1/const.SCALE_FACTOR/2, 1/const.SCALE_FACTOR/2, self.image:getWidth()/2, self.image:getHeight()/2)

            love.graphics.setColor(1, 1, 0)
            self.player:draw()

            love.graphics.setColor(0, 1, 0)
            love.graphics.points(0, 0)
        self.camera:detach()
    end)

    love.graphics.setShader(shaders.light)
    self.canvas:drawAll()
    love.graphics.setShader()

    local x, y = self.player:getPosition()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("X: " .. x .. "\nY: " .. y, 10, 10)
    love.graphics.print("Light: " .. self.lightRadius, 10, 50)
end

return maingame