local class = require "middleclass"


local ViewSystem = require "game.systems.view_system"
local InputSystem = require "game.systems.input_system"
local CollisionSystem = require "game.systems.collision_system"
local AISystem = require "game.systems.ai_system"

local Position = require "game.components.position"
local Player = require "game.components.player"
local Drawable = require "game.components.drawable"
local Collider = require "game.components.collider"
local Brain = require "game.components.brain"
local Focus = require "game.components.focus"

local CreatureGenerator = require "data.creature_generator"

local ColliderClasses = require "game.enums.collider_classes"
local ColliderTypes = require "game.enums.collider_types"
local Creatures = require "data.enums.creatures"


local Gameplay = class("Gameplay")

function Gameplay:initialize(data)
    self.event_manager = data.event_manager
    self.game_logic = data.game_logic

    self.engine = Engine()

    self.ai_system = AISystem()
    self.view_system = ViewSystem(
        {
            engine = self.engine,
            ai_system = self.ai_system,
            game_logic = self.game_logic
        }
    )

    self.engine:addSystem(self.view_system, "update")
    self.engine:addSystem(self.ai_system, "update")
    self.engine:addSystem(CollisionSystem({event_manager = self.event_manager}), "update")
    self.engine:addSystem(InputSystem(), "update")

    self.engine:addSystem(self.view_system, "draw")
    -- self.engine:addSystem(self.ai_system, "draw")

    self.creature_generator = CreatureGenerator()
end

function Gameplay:enter(owner)
    self:_register_components()

    local level = self.game_logic:get_level_data()

    self.view_system:set_map(level:get_map())
    self.ai_system:set_map(level)

    local creatures = level:get_creatures()

    for _, creature in ipairs(creatures) do
        if creature.name == "player" then
            local player = Entity()
            player:initialize()

            player:add(Position({x = creature.x, y = creature.y}))
            player:add(Player())
            player:add(Drawable(self.creature_generator:get_creature(Creatures.player)))
            player:add(Collider({class = ColliderClasses.player, type = ColliderTypes.moving, speed = 150}))
            player:add(Focus())

            self.engine:addEntity(player)
        end

        if creature.name == "soldier" then
            local soldier = Entity()
            soldier:initialize()

            soldier:add(Brain(creature.name))
            soldier:add(Position({x = creature.x, y = creature.y}))
            soldier:add(Drawable(self.creature_generator:get_creature(Creatures.soldier)))
            soldier:add(Collider({class = ColliderClasses.NPC, type = ColliderTypes.moving, speed = 90}))

            self.engine:addEntity(soldier)
        end
    end

    local obstacles = level:get_obstacles()

    for _, obstacle in ipairs(obstacles) do
        local wall = Entity()
        wall:initialize()

        wall:add(Collider(
            {
                class = ColliderClasses.wall,
                type = ColliderTypes.fixed,
                vertex = {x = obstacle.x, y = obstacle.y, width = obstacle.width, height = obstacle.height}
            }
        ))

        self.engine:addEntity(wall)
    end

    local transitions = level:get_transitions()

    for _, transition in ipairs(transitions) do
        local door = Entity()
        door:initialize()

        door:add(Collider(
            {
                class = ColliderClasses.transition,
                type = ColliderTypes.fixed,
                vertex = {x = transition.x, y = transition.y, width = transition.width, height = transition.height},
                collider_name = transition.name
            }
        ))

        self.engine:addEntity(door)
    end
end

function Gameplay:execute(owner, dt)
    self.engine:update(dt)
end

function Gameplay:draw(owner)
    self.engine:draw()
end

function Gameplay:exit(owner)
    local colliders = self.engine:getEntitiesWithComponent(Collider.name)

    for _, collider in ipairs(colliders) do
        self.engine:removeEntity(collider)
    end

    local draw_entitys = self.engine:getEntitiesWithComponent(Drawable.name)

    for _, draw_entity in ipairs(draw_entitys) do
        self.engine:removeEntity(draw_entity)
    end

    local players_entity = self.engine:getEntitiesWithComponent(Player.name)

    for _, player_entity in ipairs(players_entity) do
        self.engine:removeEntity(player_entity)
    end

    local positions = self.engine:getEntitiesWithComponent(Position.name)

    for _, position in ipairs(positions) do
        self.engine:removeEntity(position)
    end

    local brains = self.engine:getEntitiesWithComponent(Brain.name)

    for _, brain in ipairs(brains) do
        self.engine:removeEntity(brain)
    end
end

function Gameplay:_register_components()
    for _, component in pairs(self:_components()) do
        Component.register(component)
    end
end

function Gameplay:_components()
    return {
        Position,
        Player,
        Drawable,
        Collider,
        Brain,
        Focus
    }
end

return Gameplay
