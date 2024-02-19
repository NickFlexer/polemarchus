local class = require "middleclass"


local Collider = class("Collider")

function Collider:initialize(data)
    self.col_class = data.class
    self.col_type = data.type
    self.speed = data.speed
    self.vertex = data.vertex
    self.collider_name = data.collider_name
    self.collider = nil

    self.vx = 0
    self.vy = 0
end

function Collider:get_class()
    return self.col_class
end

function Collider:get_type()
    return self.col_type
end

function Collider:set_collider(collider)
    self.collider = collider
end

function Collider:get_collider()
    return self.collider
end

function Collider:get_speed()
    return self.speed
end

function Collider:set_impulse(vx, vy)
    self.vx, self.vy = vx, vy
end

function Collider:get_impulse()
    return self.vx, self.vy
end

function Collider:get_vertex()
    return self.vertex
end

function Collider:get_name()
    return self.collider_name
end

return Collider
