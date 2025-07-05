local sceneManager = require("src.scenes.sceneManager")
local shaders = require("src.shaders.shaders")

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.mouse.setVisible(false)

    shaders.load()
    sceneManager:load("intro")
end

function love.update(dt)
    sceneManager:update(dt)
end

function love.draw()
    sceneManager:draw()
end

function love.keyreleased(key, _, _)
    sceneManager:keypressed(key)

    if key == "escape" then
        love.event.quit()
    elseif key == "f11" then
    end
end

function love.resize(w, h)
end