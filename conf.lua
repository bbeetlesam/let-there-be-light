function love.conf(t)
    t.window.title = "Maro's Misfortune"
    t.window.icon = nil
    t.window.width = 1920
    t.window.height = 1200
    t.window.resizable = true
    t.window.fullscreen = true
    t.window.minwidth = 1920/2
    t.window.minheight = 1200/2
    t.window.vsync = 0

    -- for debugging
    t.version = "11.5"
    t.console = false
    t.identity = nil
    t.window.display = 2
end