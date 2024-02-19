local class = require "middleclass"


local StartGameplayEvent = class("StartGameplayEvent")

function StartGameplayEvent:initialize(level_name)
    self.level_name = level_name
end

function StartGameplayEvent:get_name()
    return self.level_name
end

return StartGameplayEvent
