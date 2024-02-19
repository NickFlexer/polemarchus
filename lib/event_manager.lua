local class = require "middleclass"


local EventManager = class("EventManager")

function EventManager:initialize(data)
    self.listeners = {}
end

function EventManager:add_listener(event_name, listener, listener_function)
    if not self.listeners[event_name] then
        self.listeners[event_name] = {}
    end

    table.insert(self.listeners[event_name], {listener, listener_function})
end

function EventManager:remove_listener(event_name, listener)
    for key, registered_listener in pairs(self.listeners[event_name]) do
        if registered_listener[1].class.name == listener then
            table.remove(self.listeners[event_name], key)

            return
        end
    end
end

function EventManager:post_event(event)
    local event_name = event.class.name

    if self.listeners[event_name] then
        for _, listener in pairs(self.listeners[event_name]) do
            listener[2](listener[1], event)
        end
    end
end

return EventManager
