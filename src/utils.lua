local utils = {}

-- return screen based coord to world (game) based coord
function utils.screenToWorld(x, y)
    local const = require("src.const")

    local scaleX = const.SCREEN_WIDTH / const.GAME_WIDTH
    local scaleY = const.SCREEN_HEIGHT / const.GAME_HEIGHT
    return x * scaleX, y * scaleY
end

-- return world (game) based coord to screen based coord
function utils.worldToScreen(x, y)
    local const = require("src.const")

    local scaleX = const.SCREEN_WIDTH / const.GAME_WIDTH
    local scaleY = const.SCREEN_HEIGHT / const.GAME_HEIGHT
    return x / scaleX, y / scaleY
end

function utils.isValueAround(value, low, up)
    return value >= low and value <= up
end

-- animate spritesheet with quad tables (frames)
-- NOTE: fps is how many sprite will be shown per second, not the frame speed
function utils.animateSpritesheet(frames, mode, fps)
    local self = {}
    self.frames = frames
    self.mode = mode or "loop"
    self.timer = 0
    self.fps = fps or 10
    self.index = 1
    self.forward = true

    function self:update(dt)
        self.timer = self.timer + dt
        if self.timer >= 1 / self.fps then
            self.timer = self.timer - 1 / self.fps
            if self.mode == "loop" then
                self.index = self.index % #self.frames + 1
            elseif self.mode == "forth" then
                if self.forward then
                    self.index = self.index + 1
                    if self.index > #self.frames then
                        self.index = #self.frames - 1
                        self.forward = false
                    end
                else
                    self.index = self.index - 1
                    if self.index < 1 then
                        self.index = 2
                        self.forward = true
                    end
                end
            end
        end
    end

    function self:getFrame()
        return self.frames[self.index]
    end

    function self:setFPS(fps2)
        self.fps = fps2 or 10
    end

    return self
end

return utils