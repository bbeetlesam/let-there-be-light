local sounds = {}

function sounds.load()
    sounds.beerClang = love.audio.newSource("assets/sfx/beer-clang.ogg", "static")
    sounds.step = love.audio.newSource("assets/sfx/step.wav", "static")
    sounds.doorOpen = love.audio.newSource("assets/sfx/open-door.wav", "static")
    sounds.shepard = love.audio.newSource("assets/sfx/shepard-main.wav", "stream")
    sounds.tvTalking = love.audio.newSource("assets/sfx/tv-talking.wav", "stream")
    sounds.crying = love.audio.newSource("assets/sfx/crying.wav", "stream")
    sounds.paperFlip = love.audio.newSource("assets/sfx/paper-flip.wav", "static")
    sounds.openWardrobe = love.audio.newSource("assets/sfx/open-wardrobe.wav", "static")
end

return sounds