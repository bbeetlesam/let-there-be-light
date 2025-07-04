local const = require("src.const")
local CanvasManager = require("src.canvas")
local utils = require("src.utils")
local Player = require("src.player")
local Camera = require("src.camera")
local shaders = require("src.shaders.shaders")

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    image = love.graphics.newImage("dump/octocat-1747987801490.png")
    lightRadius = 500

    player = Player:new(const.GAME_WIDTH/2, const.GAME_HEIGHT/2)
    camera = Camera:new(0, 0, 1)

    canvases = CanvasManager:new()
    canvases:create("main", const.GAME_WIDTH, const.GAME_HEIGHT, const.SCALE_FACTOR, {"nearest", "nearest"})
    -- canvases:addShader("main", shaders.light)
    shaders.load()
end

function love.update(dt)
    if love.keyboard.isDown("up") and lightRadius < 1500 then
        lightRadius = lightRadius + 900 * dt
    elseif love.keyboard.isDown("down") and lightRadius > 100 then
        lightRadius = lightRadius - 900 * dt
    end

    player:update(dt)
    local x, y = player:getPosition()
    camera:setPosition(x, y)

    local a, b = utils.screenToWorld(const.GAME_WIDTH/2, const.GAME_HEIGHT/2 - 10)
    shaders.light:send("lightPos", {a, b})
    shaders.light:send("radius", lightRadius)
end

function love.draw()
    canvases:with("main", function()
        love.graphics.setColor(love.math.colorFromBytes(17, 17, 17))
        love.graphics.rectangle("fill", 0, 0, const.GAME_WIDTH, const.GAME_HEIGHT)

        camera:attach()
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(image, const.GAME_WIDTH/2, const.GAME_HEIGHT/2, 0, 1/const.SCALE_FACTOR/2, 1/const.SCALE_FACTOR/2, image:getWidth()/2, image:getHeight()/2)

            love.graphics.setColor(1, 1, 0)
            player:draw()

            love.graphics.setColor(0, 1, 0)
            love.graphics.points(0, 0)
        camera:detach()
    end)

    love.graphics.setShader(shaders.light)
    canvases:drawAll()
    love.graphics.setShader()

    local x, y = player:getPosition()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Light: " .. lightRadius, 10, 10)
    love.graphics.print("X " .. x .. "\nY " .. y, 10, 40)
end

function love.keyreleased(key, _, _)
    if key == "escape" then
        love.event.quit()
    elseif key == "f11" then 
    end
end

function love.resize(w, h)
end