local Counter = {}

local Constants = require('src.util.constants')
local State = require('src.models.state')

function Counter.createCounter(Color, ScriptingZone)
  local PositionVector

  if Color == 'Blue' or Color == "Yellow" then
    PositionVector = vector(-10, 0, 0)
  elseif Color == 'Purple' or Color == "Green" then
    PositionVector = vector(10, 0, 0)
  else
    PositionVector = vector(0, 0, 10)
  end

  local Checker = spawnObject({
    type = "Checker_black",
    position = ScriptingZone.getPosition() + PositionVector,
    scale = { 1, 1, 1 },
    rotation = ScriptingZone.getRotation() + vector(0, 180, 0),
  })

  Checker.setInvisibleTo(Constants.AvailableColors)
  Checker.setLock(true)
  Checker.interactable = false

  State.updateCounterValue(Color, ScriptingZone.getGUID(), Checker.getGUID())

  Counter.setCheckerValue(Color, Checker, 0)
end

function Counter.setCheckerValue(Color, Checker, Value)
  State.updateCounterValue(Color, Checker.getGUID(), Value)
  refreshXml(Color, Checker)
end

function refreshXml(Color, Checker)
  Checker.UI.setXml("<Text position='0, -10, 0' fontSize='400' color='White'>" ..
    State.getState().Counters[Color][Checker.getGUID()] .. "</Text>")
end

return Counter
