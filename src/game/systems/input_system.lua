local class = require "middleclass"

local Input = require "Input"

local Player = require "game.components.player"
local Collider = require "game.components.collider"
local Drawable = require "game.components.drawable"

local Directions = require "game.enums.directions"


local InputSystem = class("InputSystem", System)


function InputSystem:initialize(data)
    System.initialize(self)

    self.input = Input()

    self.input:bind("w", "up")
    self.input:bind("s", "down")
    self.input:bind("d", "right")
    self.input:bind("a", "left")
end

function InputSystem:update(dt)
    for _, entity in pairs(self.targets) do
        entity:get(Drawable.name):stop_moving()

        local vx, vy = 0, 0

        if self.input:down("up") then
            vy =  entity:get(Collider.name):get_speed() * -1
            entity:get(Drawable.name):set_anim_direction(Directions.up)
            entity:get(Drawable.name):start_moving()
        elseif self.input:down("down") then
            vy =  entity:get(Collider.name):get_speed()
            entity:get(Drawable.name):set_anim_direction(Directions.down)
            entity:get(Drawable.name):start_moving()
        elseif self.input:down("right") then
            vx =  entity:get(Collider.name):get_speed()
            entity:get(Drawable.name):set_anim_direction(Directions.right)
            entity:get(Drawable.name):start_moving()
        elseif self.input:down("left") then
            vx =  entity:get(Collider.name):get_speed() * -1
            entity:get(Drawable.name):set_anim_direction(Directions.left)
            entity:get(Drawable.name):start_moving()
        end

        entity:get(Collider.name):set_impulse(vx, vy)
    end
end

function InputSystem:requires()
    return {Player.name}
end

function InputSystem:onAddEntity(entity)
    -- body
end

function InputSystem:onRemoveEntity(entity)
    -- body
end

return InputSystem
