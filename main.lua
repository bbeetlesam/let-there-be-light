local sceneManager = require("src.scenes.sceneManager")
local shaders = require("src.shaders.shaders")
local sounds = require("src.sounds")

function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.mouse.setVisible(false)

    shaders.load()
    sounds.load()
    sceneManager:load("intro")

    print("game started.")
end

function love.update(dt)
    sceneManager:update(dt)
end

function love.draw()
    sceneManager:draw()

    -- for debugging
    -- love.graphics.print((sceneManager:getCurrentSceneId()), 10, 800)
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