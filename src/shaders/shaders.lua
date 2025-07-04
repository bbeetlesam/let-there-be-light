local shaders = {}

function shaders.load()
    shaders.light = love.graphics.newShader("src/shaders/thelight.glsl")
end

return shaders