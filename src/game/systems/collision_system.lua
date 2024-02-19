local class = require "middleclass"

local Collisions = require "windfield"

local Collider = require "game.components.collider"
local Position = require "game.components.position"

local Settings = require "data.settings"

local ColliderClasses = require "game.enums.collider_classes"
local ColliderTypes = require "game.enums.collider_types"

local StartGameplayEvent = require "game.events.start_gameplay_event"


local CollisionSystem = class("CollisionSystem", System)

function CollisionSystem:initialize(data)
    System.initialize(self)

    self.event_manager = data.event_manager

    self.world = Collisions.newWorld(0, 0)
    self.world:addCollisionClass(ColliderClasses.wall)
    self.world:addCollisionClass(ColliderClasses.transition)
    self.world:addCollisionClass(ColliderClasses.player, {ignores = {ColliderClasses.transition}})
    self.world:addCollisionClass(ColliderClasses.NPC, {ignores = {ColliderClasses.transition}})
end

function CollisionSystem:update(dt)
    for _, entity in pairs(self.targets) do
        if entity:get(Collider.name):get_type() == ColliderTypes.moving then
            local vx, vy = entity:get(Collider.name):get_impulse()
            entity:get(Collider.name):get_collider():setLinearVelocity(vx, vy)

            entity:get(Position.name):set(
                entity:get(Collider.name):get_collider():getX() - Settings.tile_size / 2,
                entity:get(Collider.name):get_collider():getY() - Settings.tile_size / 2
            )

            if entity:get(Collider.name):get_class() == ColliderClasses.player then
                if entity:get(Collider.name):get_collider():enter(ColliderClasses.transition) then
                    local collision_data = entity:get(Collider.name):get_collider():getEnterCollisionData(ColliderClasses.transition)
                    self.event_manager:post_event(StartGameplayEvent(collision_data.collider:getObject().name))
                end

                if entity:get(Collider.name):get_collider():enter(ColliderClasses.NPC) then
                    local collision_data = entity:get(Collider.name):get_collider():getEnterCollisionData(ColliderClasses.NPC)
                    -- self.event_manager:post_event(StartGameplayEvent(collision_data.collider:getObject().name))
                    print(entity)
                end
            end
        end
    end

    self.world:update(dt)
end

function CollisionSystem:requires()
    return {Collider.name}
end

function CollisionSystem:onAddEntity(entity)
    -- if entity:get(Collider.name):get_class() == ColliderClasses.player then
    if entity:get(Collider.name):get_type() == ColliderTypes.moving then
        local collider = self.world:newBSGRectangleCollider(
            entity:get(Position.name):get_x(),
            entity:get(Position.name):get_y(),
            Settings.tile_size,
            Settings.tile_size,
            Settings.tile_size / 4
        )

        collider:setFixedRotation(true)
        collider:setCollisionClass(entity:get(Collider.name):get_class())
        collider:setObject({name = entity:get(Collider.name):get_name()})

        entity:get(Collider.name):set_collider(collider)
    elseif entity:get(Collider.name):get_class() == ColliderClasses.wall then
        local vertex = entity:get(Collider.name):get_vertex()

        local collider = self.world:newRectangleCollider(
            vertex.x,
            vertex.y,
            vertex.width,
            vertex.height
        )

        collider:setType("static")
        collider:setCollisionClass(entity:get(Collider.name):get_class())

        entity:get(Collider.name):set_collider(collider)
    elseif entity:get(Collider.name):get_class() == ColliderClasses.transition then
        local vertex = entity:get(Collider.name):get_vertex()

        local collider = self.world:newRectangleCollider(
            vertex.x,
            vertex.y,
            vertex.width,
            vertex.height
        )

        collider:setType("static")
        collider:setCollisionClass(entity:get(Collider.name):get_class())
        collider:setObject({name = entity:get(Collider.name):get_name()})
    end
end

function CollisionSystem:onRemoveEntity(entity)
    if entity:get(Collider.name):get_collider() then
        local collider = entity:get(Collider.name):get_collider()
        collider:destroy()
    end
end

return CollisionSystem
