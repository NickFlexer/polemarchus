local class = require "middleclass"

local Camera = require "Camera"
local anim8 = require "anim8"

local Position = require "game.components.position"
local Drawable = require "game.components.drawable"
local Focus = require "game.components.focus"

local Settings = require "data.settings"


local ViewSystem = class("ViewSystem", System)

function ViewSystem:initialize(data)
    System.initialize(self)

    self.engine = data.engine
    self.ai_system = data.ai_system
    self.game_logic = data.game_logic

    self.map = nil

    self.camera = Camera()
    self.camera.scale = 2
    self.camera:setFollowLerp(0.2)
    self.camera:setFollowStyle("TOPDOWN_TIGHT")
end

function ViewSystem:update(dt)
    for _, focus in pairs(self.targets.focus_points) do
        local follow_x, follow_y = focus:get(Position.name):get()
        self.camera:follow(follow_x, follow_y)
    end

    self.camera:update(dt)

    for _, entity in pairs(self.targets.drawable) do
        if not entity:get(Drawable.name):is_moving() then
            entity:get(Drawable.name):get_anim():gotoFrame(entity:get(Drawable.name):get_stand_frame())
        end

        entity:get(Drawable.name):get_anim():update(dt)
    end
end

function ViewSystem:draw()
    self.camera:attach()

    self.map:drawLayer(self.map.layers["ground"])
    self.map:drawLayer(self.map.layers["items"])

    for _, entity in pairs(self.targets.drawable) do
        entity:get(Drawable.name):get_anim():draw(
            entity:get(Drawable.name):get_spritesheet(),
            entity:get(Position.name):get_x(),
            entity:get(Position.name):get_y()
        )

        -- love.graphics.circle("fill", entity:get(Position.name):get_x(), entity:get(Position.name):get_y(), 2)
    end

    self.map:drawLayer(self.map.layers["shadows"])

    -- self.ai_system:draw()

    self.camera:detach()

    self.camera:draw()
end

function ViewSystem:requires()
    return {drawable = {Drawable.name}, focus_points = {Focus.name}}
end

function ViewSystem:onAddEntity(entity, group)
    if group == "drawable" and entity:has(Drawable.name) then
        local animation_data = entity:get(Drawable.name):get_raw_data()

        local grid = anim8.newGrid(
            Settings.tile_size,
            Settings.tile_size,
            animation_data.sprite_sheet:getWidth(),
            animation_data.sprite_sheet:getHeight()
        )

        entity:get(Drawable.name):set_grid(grid)

        local animations = {}

        for key, value in pairs(animation_data.animation_data) do
            animations[key] = anim8.newAnimation(grid(value.frames[1], value.frames[2]), value.durations)
        end

        entity:get(Drawable.name):set_animations(animations)
        entity:get(Drawable.name):set_anim(entity:get(Drawable.name):get_default_anim())
    end
end

function ViewSystem:onRemoveEntity(entity)
    -- body
end

function ViewSystem:set_map(map)
    self.map = map
end

return ViewSystem
