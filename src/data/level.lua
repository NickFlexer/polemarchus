local class = require "middleclass"

local STI = require "sti"


local Level = class("Level")

function Level:initialize(data)
    self.map = STI(data)
end

function Level:get_map()
    return self.map
end

function Level:get_creatures()
    return self.map.layers["creatures"].objects
end

function Level:get_obstacles()
    if self.map.layers["walls"].objects then
        return self.map.layers["walls"].objects
    end

    return {}
end

function Level:get_transitions()
    if self.map.layers["transitions"].objects then
        return self.map.layers["transitions"].objects
    end

    return {}
end

function Level:get_way_points()
    if self.map.layers["way_points"] then
        return self.map.layers["way_points"].objects
    end

    return {}
end

return Level
