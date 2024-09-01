local class = require "middleclass"


local SeverTest = class("SeverTest")

function SeverTest:initialize()
    
end

function SeverTest:plot()
    appears("player") -- загрузить игрока
    in_focus("player") -- камера направляется на игрока
    free_gameplay() -- запуск геймплея
end

return
