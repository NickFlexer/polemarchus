local class = require "middleclass"


local Position = class("Position")

function Position:initialize(data)
    self.x = 0
    self.y = 0

    if data then
        self.x = data.x
        self.y = data.y
    end
end

function Position:set(x, y)
    self.x = x
    self.y = y
end

function Position:get()
    return self.x, self.y
end

function Position:get_x()
    return self.x
end

function Position:get_y()
    return self.y
end

return Position
