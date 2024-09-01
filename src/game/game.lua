local class = require "middleclass"

local FSM = require "fsm"
local EvemtManager = require "event_manager"

local MainMenu = require "game.states.main_menu"
local Gameplay = require "game.states.gameplay"

local StartGameplayEvent = require "game.events.start_gameplay_event"

local GameLogic = require "logic.game_logic"
local LevelLogic = require "logic.level_logic"


local Game = class("Game")

function Game:initialize(data)
    self.event_manager = EvemtManager()
    self.fsm = FSM(self)
    self.game_logic = GameLogic()

    self.states = {
        main_menu = MainMenu({event_manager = self.event_manager}),
        gameplay = Gameplay({
            event_manager = self.event_manager,
            game_logic = self.game_logic
        })
    }

    self.fsm:set_current_state(self.states.main_menu)

    self.event_manager:add_listener(StartGameplayEvent.name, self, self.handle_events)
end

function Game:update(dt)
    self.fsm:update(dt)
end

function Game:draw()
    if self.fsm:get_current_state() then
        self.fsm:get_current_state():draw()
    end
end

function Game:handle_events(event)
    local level_logic = LevelLogic()

    if event.class.name == StartGameplayEvent.name then
        self.game_logic:set_level_data(level_logic:get_level(event:get_name()))

        self.fsm:change_state(self.states.gameplay)
    end
end

return Game
