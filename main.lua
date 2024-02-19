package.path = package.path .. ";lib/?/init.lua;lib/?.lua;src/?.lua"


local lovetoys = require "lovetoys"

lovetoys.initialize({
    globals = true,
    debug = true
})


local Game = require "game.game"


local game


function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    game = Game()
end


function love.update(dt)
    if dt < 1/60 then
        love.timer.sleep(1/60 - dt)
    end

    game:update(dt)
end


function love.draw()
    game:draw()
end
