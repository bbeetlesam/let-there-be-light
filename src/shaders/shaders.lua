local shaders = {}

function shaders.load()
    shaders.light = love.graphics.newShader("src/shaders/thelight.glsl")
    shaders.foggyRect = love.graphics.newShader("src/shaders/foggyRect.glsl")
end

return shaders