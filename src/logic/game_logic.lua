local class = require "middleclass"

local Settings = require "data.settings"


local GameLogic = class("GameLogic")

function GameLogic:initialize(data)
    self.level = nil

    self.focus_x = nil
    self.focus_y = nil
end

function GameLogic:set_level_data(level_data)
    self.level = level_data

    self.focus_x = self.level:get_map().width * Settings.tile_size / 2
    self.focus_y = self.level:get_map().height * Settings.tile_size / 2
end

function GameLogic:get_level_data(level_data)
    return self.level
end

function GameLogic:focus_point()
    return self.focus_x, self.focus_y
end

return GameLogic
