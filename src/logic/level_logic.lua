local class = require "middleclass"

local Level = require "src.data.level"


local LevelLogic = class("LevelLogic")

function LevelLogic:initialize(data)
    self.levels = {
        sewer_test = "res/maps/test_map/sewer_test.lua",
        sewer_corridor = "res/maps/test_map/sewer_corridor.lua"
    }
end

function LevelLogic:get_level(name)
    if not name then
        return Level(self.levels.sewer_test)
    else
        return Level(self.levels[name])
    end
end

return LevelLogic
