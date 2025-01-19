local CounterManager = {}

local Counter = require('src.models.counter')
local State = require('src.models.state')

function CounterManager.StartGame()
  log('Spawning initial counters')
  for _, Color in pairs(State.getState().SeatedPlayers) do
    State.initializeCounterColor(Color)

    local Player = State.getObjectList().Players[Color]
    Counter.createCounter(Color, Player.ScriptLeft)
    Counter.createCounter(Color, Player.ScriptMiddle)
    Counter.createCounter(Color, Player.ScriptRight)
  end
end

return CounterManager
