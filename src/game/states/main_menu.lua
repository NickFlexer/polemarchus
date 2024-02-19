local class = require "middleclass"

local SUIT = require "suit"

local StartGameplayEvent = require "game.events.start_gameplay_event"


local MainMenu = class("MainMenu")

function MainMenu:initialize(data)
    self.event_manager = data.event_manager

    self.ui = SUIT.new()

    self.button_size = 32
    self.window_width = nil
    self.window_height = nil
    self.font = love.graphics.newFont("res/fonts/keyrusMedium.ttf", 18)
end

function MainMenu:enter(owner)
    self.window_width, self.window_height = love.window.getMode()
end

function MainMenu:execute(owner, dt)
    self.ui.layout:reset(self.window_width / 2 - self.button_size * 4, self.button_size * 8)
    self.ui.layout:padding(0, self.button_size / 4)

    self.ui:Label(
        "JRPG engine test",
        {align = "center", font = self.font},
        self.ui.layout:row(self.button_size * 8, self.button_size)
    )

    if self.ui:Button("Start", {align = "center", font = self.font}, self.ui.layout:row()).hit then
        self.event_manager:post_event(StartGameplayEvent())
    end
end

function MainMenu:draw(owner)
    self.ui:draw()
end

function MainMenu:exit(owner)
    
end

return MainMenu
