local CounterManager = {}

local Counter = require('src.models.counter')

local ObjectList
local State

function CounterManager.StartGame(GObjectList, GState)
  ObjectList = GObjectList
  State = GState

  log('Spawning initial counters')
  State.Counters = {}
  for _, Color in pairs(State.SeatedPlayers) do
    State.Counters[Color] = {}

    local Player = ObjectList.Players[Color]
    Counter.createCounter(ObjectList, State, Color, Player.ScriptLeft)
    Counter.createCounter(ObjectList, State, Color, Player.ScriptMiddle)
    Counter.createCounter(ObjectList, State, Color, Player.ScriptRight)
  end
end

return CounterManager
