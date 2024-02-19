local class = require "middleclass"

local Directions = require "game.enums.directions"
local Creatures = require "data.enums.creatures"


local CreatureGenerator = class("CreatureGenerator")

function CreatureGenerator:initialize()
    
end

function CreatureGenerator:get_creature(name)
    local data = nil

    if name == Creatures.player then
        data = {
            sprite_sheet = love.graphics.newImage("res/sprites/AH_SpriteSheet_People1.png"),
            animation_data = {
                [Directions.down] = {frames = {"1-3", 1}, durations = 0.2},
                [Directions.up] = {frames = {"1-3", 4}, durations = 0.2},
                [Directions.left] = {frames = {"1-3", 2}, durations = 0.2},
                [Directions.right] = {frames = {"1-3", 3}, durations = 0.2}
            },
            stand_frame = 2
        }
    elseif name == Creatures.soldier then
        data = {
            sprite_sheet = love.graphics.newImage("res/sprites/AH_SpriteSheet_People1.png"),
            animation_data = {
                [Directions.down] = {frames = {"7-9", 5}, durations = 0.2},
                [Directions.up] = {frames = {"7-9", 8}, durations = 0.2},
                [Directions.left] = {frames = {"7-9", 6}, durations = 0.2},
                [Directions.right] = {frames = {"7-9", 7}, durations = 0.2}
            },
            stand_frame = 2
        }
    end

    return data
end

return CreatureGenerator
