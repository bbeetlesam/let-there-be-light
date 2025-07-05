local sceneManager = {
    current = nil
}

function sceneManager:load(sceneName)
    local scene = require("src.scenes." .. sceneName)
    self.current = scene
    if self.current.load then
        self.current:load()
    end
end

function sceneManager:getCurrentScene()
    return self.current
end

function sceneManager:update(dt)
    if self.current and self.current.update then
        self.current:update(dt)
    end
end

function sceneManager:draw()
    if self.current and self.current.draw then
        self.current:draw()
    end
end

function sceneManager:keypressed(key)
    if self.current and self.current.keypressed then
        self.current:keypressed(key)
    end
end

return sceneManager