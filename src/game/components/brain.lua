local class = require "middleclass"

local luastar = require("lua-star")
local Vector = require "hump.vector"

local Settings = require "data.settings"


local Brain = class("Brain")

function Brain:initialize(owner_name)
    self.owner_name = owner_name

    self.way_points = {}
    self.path = {}
    self.index = 1

    self.startup = true
end

function Brain:get_owner_name()
    return self.owner_name
end

function Brain:add_way_point(way_point)
    table.insert(self.way_points, way_point)
end

function Brain:update(x, y, map)
    local cur_x = x + Settings.tile_size / 2
    local cur_y = y + Settings.tile_size / 2

    if self.startup then
        self:_calculate_path(
            self:_get_local_pos(cur_x),
            self:_get_local_pos(cur_y),
            self.way_points[self.index].x,
            self.way_points[self.index].y,
            map
        )

        self.startup = false
    end

    if not self:_is_path_finished() then
        local aim_pos = self:_get_current_path_position()

        local aim_x = aim_pos.x
        local aim_y = aim_pos.y

        local entity_pos_x = self:_get_local_pos(cur_x + 4)
        local entity_pos_y = self:_get_local_pos(cur_y + 4)

        local target = Vector.new(aim_x, aim_y)
        local pos = Vector.new(entity_pos_x, entity_pos_y)
        local dir = (target - pos)

        -- print("pos:"..  pos.x .."," .. pos.y .. " target: " .. aim_x .. "," .. aim_y)

        if target == pos then
            self:_set_next_path_position()
        end

        return {x = math.floor(dir.x), y = math.floor(dir.y)}
    else
        self.index = self.index + 1

        if self.index > #self.way_points then
            self.index = 1
        end

        self:_calculate_path(
            self:_get_local_pos(cur_x),
            self:_get_local_pos(cur_y),
            self.way_points[self.index].x,
            self.way_points[self.index].y,
            map
        )
    end

    return {x = 0, y = 0}
end

function Brain:_calculate_path(start_x, start_y, goal_x, goal_y, map)
    local size_x, size_y = map:get_size()

    self.path = luastar:find(
        size_x,
        size_y,
        {x = start_x, y = start_y},
        {x = goal_x, y = goal_y},
        function (x, y)
            return map:get_cell(x, y) == 0
        end,
        false,
        true
    )
end

function Brain:_get_current_path_position()
    return self.path[1]
end

function Brain:_is_path_finished()
    return #self.path == 0
end

function Brain:_set_next_path_position()
    table.remove(self.path, 1)
end

function Brain:_get_world_pos(local_pos)
    return (local_pos - 1) * Settings.tile_size
end

function Brain:_get_local_pos(world_pos)
    return math.floor(world_pos / Settings.tile_size) + 1
end

return Brain
