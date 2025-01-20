-- local CounterManager = {}

-- local Counter = require('src.models.counter')
-- local State = {}

-- function CounterManager.StartGame()
--   log('Spawning initial counters')
--   for _, Color in pairs(getSeatedPlayers()) do
--     State.initializeCounterColor(Color)

--     local Player = State.getObjectList().Players[Color]
--     Counter.createCounter(Color, Player.ScriptLeft)
--     Counter.createCounter(Color, Player.ScriptMiddle)
--     Counter.createCounter(Color, Player.ScriptRight)
--   end
-- end

-- return CounterManager
