local class = require "middleclass"

local Directions = require "game.enums.directions"


local Drawable = class("Drawable")

function Drawable:initialize(data)
    self.raw_data = data

    self.grid = nil
    self.animations = nil
    self.anim = nil
    self.moving = false
end

function Drawable:get_raw_data()
    return self.raw_data
end

function Drawable:get_spritesheet()
    return self.raw_data.sprite_sheet
end

function Drawable:set_grid(grid)
    self.grid = grid
end

function Drawable:set_animations(animations)
    self.animations = animations
end

function Drawable:get_default_anim()
    return self.animations[Directions.down]
end

function Drawable:set_anim(anim)
    self.anim = anim
end

function Drawable:set_anim_direction(direction)
    self.anim = self.animations[direction]
end

function Drawable:get_anim()
    return self.anim
end

function Drawable:is_moving()
    return self.moving
end

function Drawable:stop_moving()
    self.moving = false
end

function Drawable:start_moving()
    self.moving = true
end

function Drawable:get_stand_frame()
    return self.raw_data.stand_frame
end

return Drawable
