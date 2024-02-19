local class = require "middleclass"

local Grid = require "grid"
local Vector = require "hump.vector"

local Brain = require "game.components.brain"
local Collider = require "game.components.collider"
local Drawable = require "game.components.drawable"
local Position = require "game.components.position"

local Directions = require "game.enums.directions"

local Settings = require "data.settings"


local AISystem = class("AISystem", System)

function AISystem:initialize(data)
    System.initialize(self)

    self.map = nil
    self.way_points = nil
end

function AISystem:update(dt)
    for _, entity in pairs(self.targets) do
        -- entity:get(Drawable.name):stop_moving()

        local cur_x, cur_y = entity:get(Position.name):get()

        local direction =  entity:get(Brain.name):update(cur_x, cur_y, self.map)
        local vx, vy = 0, 0

        if direction.y < 0 then
            vy = entity:get(Collider.name):get_speed() * -1
            entity:get(Drawable.name):set_anim_direction(Directions.up)
            entity:get(Drawable.name):start_moving()
        elseif direction.y > 0 then
            vy = entity:get(Collider.name):get_speed()
            entity:get(Drawable.name):set_anim_direction(Directions.down)
            entity:get(Drawable.name):start_moving()
        elseif direction.x > 0 then
            vx = entity:get(Collider.name):get_speed()
            entity:get(Drawable.name):set_anim_direction(Directions.right)
            entity:get(Drawable.name):start_moving()
        elseif direction.x < 0 then
            vx = entity:get(Collider.name):get_speed() * -1
            entity:get(Drawable.name):set_anim_direction(Directions.left)
            entity:get(Drawable.name):start_moving()
        end

        entity:get(Collider.name):set_impulse(math.floor(vx), math.floor(vy))
    end
end

function AISystem:draw()
    for x, y, cell in self.map:iterate() do
        love.graphics.print(cell, (x - 1) * Settings.tile_size, (y - 1) * Settings.tile_size)
    end
end

function AISystem:requires()
    return {Brain.name}
end

function AISystem:onAddEntity(entity)
    for _, way_point in ipairs(self.way_points[entity:get(Brain.name):get_owner_name()]) do
        entity:get(Brain.name):add_way_point(way_point)
    end
end

function AISystem:onRemoveEntity(entity)
end

function AISystem:set_map(level_data)
    local map = level_data:get_map()
    self.map = Grid(map.width, map.height, 0)

    local obstacles = level_data:get_obstacles()

    for _, obstacle in ipairs(obstacles) do
        local x, y, width, height = obstacle.x, obstacle.y, obstacle.width, obstacle.height

            local x1 = math.ceil(x/Settings.tile_size) + 1
            local y1 = math.ceil(y/Settings.tile_size) + 1

            local x2 = math.ceil(width/Settings.tile_size) + x1 - 1
            local y2 = math.ceil(height/Settings.tile_size) + y1 - 1

            for i = x1, x2 do
                for j = y1, y2 do
                    if self.map:is_valid(i, j) then
                        self.map:set_cell(i, j, 1)
                    end
                end
            end
    end

    self.way_points = {}
    local way_points = level_data:get_way_points()

    for _, way_point in ipairs(way_points) do
        if not self.way_points[way_point.name] then
            self.way_points[way_point.name] = {}
        end

        self.way_points[way_point.name][way_point.properties.count] = {
            x = math.ceil(way_point.x/Settings.tile_size + 1),
            y = math.ceil(way_point.y/Settings.tile_size + 1)
        }
    end
end

return AISystem
