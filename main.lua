package.path = package.path .. ";lib/?/init.lua;lib/?.lua;src/?.lua"


local tick = require "tick"
local Input = require "Input"
local anim8 = require "anim8"
local sti = require "sti"
local Camera = require "Camera"
local Collisions = require "windfield"
local Grid = require "grid"
local Vector = require "hump.vector"


local player = {}
local enimy = {}
local input
local map
local camera
local world
local walls = {}
local transitions = {}
local map_grid

local tile_size = 16


function love.load()
    tick.framerate = 60

    world = Collisions.newWorld(0, 0)
    world:addCollisionClass("Wall")
    world:addCollisionClass("Transitions")
    world:addCollisionClass("Player", {ignores = {"Transitions"}})
    world:addCollisionClass("NPC", {ignores = {"Transitions"}})

    love.graphics.setDefaultFilter("nearest", "nearest")

    map = sti("res/map/sewer_01.lua")

    map_grid = Grid(map.width, map.height, 0)

    camera = Camera()
    camera.scale = 2
    camera:setFollowLerp(0.2)
    camera:setFollowStyle('TOPDOWN')

    local player_x, player_y = 0, 0
    local enimy_x, enimy_y = 0, 0

    if map.layers["creatures"] then
        for i, obj in pairs(map.layers["creatures"].objects) do
            if obj.name == "hero" then
                player_x, player_y = obj.x, obj.y
            end

            if obj.name == "enimy" then
                enimy_x, enimy_y = obj.x, obj.y
            end
        end
    end

    player.collider = world:newBSGRectangleCollider(player_x, player_y, tile_size, tile_size, 4)
    player.collider:setFixedRotation(true)
    player.collider:setCollisionClass("Player")
    player.x = player_x
    player.y = player_y
    player.speed = 150
    player.sprite_sheet = love.graphics.newImage("res/sprites/AH_SpriteSheet_People1.png")
    player.grid = anim8.newGrid(tile_size, tile_size, player.sprite_sheet:getWidth(), player.sprite_sheet:getHeight())
    player.animations = {
        down = anim8.newAnimation(player.grid("1-3", 1), 0.2),
        up = anim8.newAnimation(player.grid("1-3", 4), 0.2),
        left = anim8.newAnimation(player.grid("1-3", 2), 0.2),
        right = anim8.newAnimation(player.grid("1-3", 3), 0.2)
    }
    player.anim = player.animations.down

    enimy.name = "soldier"
    enimy.collider = world:newBSGRectangleCollider(enimy_x, enimy_y, tile_size, tile_size, 4)
    enimy.collider:setFixedRotation(true)
    enimy.collider:setCollisionClass("NPC")
    enimy.collider:setObject(enimy)
    enimy.x = enimy_x
    enimy.y = enimy_y
    enimy.aim_x = enimy.x + tile_size * 16
    enimy.aim_y = enimy.y + tile_size * 3
    enimy.speed = 150
    enimy.sprite_sheet = love.graphics.newImage("res/sprites/AH_SpriteSheet_People1.png")
    enimy.grid = anim8.newGrid(tile_size, tile_size, enimy.sprite_sheet:getWidth(), enimy.sprite_sheet:getHeight())
    enimy.animations = {
        down = anim8.newAnimation(enimy.grid("7-9", 5), 0.2),
        up = anim8.newAnimation(enimy.grid("7-9", 8), 0.2),
        left = anim8.newAnimation(enimy.grid("7-9", 6), 0.2),
        right = anim8.newAnimation(enimy.grid("7-9", 7), 0.2)
    }
    enimy.anim = enimy.animations.down
    enimy.is_moving = false

    if map.layers["walls"] then
        for i, obj in pairs(map.layers["walls"].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType("static")
            wall:setCollisionClass("Wall")
            table.insert(walls, wall)

            local x, y, width, height = obj.x, obj.y, obj.width, obj.height

            local x1 = math.ceil(x/tile_size + 1)
            local y1 = math.ceil(y/tile_size + 1)

            local x2 = math.ceil(width/tile_size - 1) + x1
            local y2 = math.ceil(height/tile_size - 1) + y1

            for i = x1, x2 do
                for j = y1, y2 do
                    if map_grid:is_valid(i, j) then
                        map_grid:set_cell(i, j, 1)
                    end
                end
            end
        end
    end

    if map.layers["transitions"] then
        for i, obj in pairs(map.layers["transitions"].objects) do
            local transition = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            transition:setType("static")
            transition:setCollisionClass("Transitions")
            transition:setObject(obj)
            table.insert(transitions, transition)
        end
    end

    input = Input()

    input:bind("w", "up")
    input:bind("s", "down")
    input:bind("d", "right")
    input:bind("a", "left")
end


function love.update(dt)
    local is_moving = false

    local vx, vy = 0, 0

    if input:down("up") then
        vy =  player.speed * -1
        player.anim = player.animations.up
        is_moving = true
    elseif input:down("down") then
        vy =  player.speed
        player.anim = player.animations.down
        is_moving = true
    elseif input:down("right") then
        vx =  player.speed
        player.anim = player.animations.right
        is_moving = true
    elseif input:down("left") then
        vx = player.speed * -1
        player.anim = player.animations.left
        is_moving = true
    end

    player.collider:setLinearVelocity(vx, vy)

    player.x = player.collider:getX() - 8
    player.y = player.collider:getY() - 8

    if not is_moving then
        player.anim:gotoFrame(2)
    end

    player.anim:update(dt)

    -- enimy moving
    local target = Vector.new(enimy.aim_x, enimy.aim_y)
    local pos = Vector.new(enimy.x, enimy.y)
    local dir = target - pos

    local dist_x, dist_y

    if dir:len() < tile_size/2 then
        dist_x, dist_y = 0, 0
    else
        dir:normalizeInplace()
        dist_x, dist_y = enimy.speed * dir.x, enimy.speed * dir.y
    end

    enimy.is_moving = false

    if dir.x > 0 then
        enimy.anim = enimy.animations.right
        enimy.is_moving = true
    elseif dir.x < 0 then
        enimy.anim = enimy.animations.left
        enimy.is_moving = true
    elseif dir.y > 0 then
        enimy.anim = enimy.animations.down
        enimy.is_moving = true
    elseif dir.y < 0 then
        enimy.anim = enimy.animations.up
        enimy.is_moving = true
    end

    if not enimy.is_moving then
        enimy.anim:gotoFrame(2)
    end

    enimy.anim:update(dt)

    enimy.collider:setLinearVelocity(dist_x, dist_y)
    enimy.x = enimy.collider:getX() - 8
    enimy.y = enimy.collider:getY() - 8


    world:update(dt)

    camera:follow(player.x, player.y)
    camera:update(dt)

    if player.collider:enter("Transitions") then
        local collision_data = player.collider:getEnterCollisionData("Transitions")
        print(collision_data.collider:getObject().name)
    end

    if player.collider:enter("NPC") then
        local collision_data = player.collider:getEnterCollisionData("NPC")
        print(collision_data.collider:getObject().name)
    end
end


function love.draw()
    camera:attach()
    map:drawLayer(map.layers["ground"])
    map:drawLayer(map.layers["other"])
    player.anim:draw(player.sprite_sheet, player.x, player.y)
    enimy.anim:draw(enimy.sprite_sheet, enimy.x, enimy.y)
    -- world:draw()

    --[[
    for x, y, cell in map_grid:iterate() do
        love.graphics.print(cell, (x - 1) * tile_size, (y - 1) * tile_size)
    end
    --]]

    camera:detach()

    camera:draw()

    love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end

