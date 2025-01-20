local Counter = {}

local Constants = require('src.util.constants')
local State = {
  CounterValue = 0
}

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

  Counter.setCheckerValue(Checker, 0)
end

function Counter.setCheckerValue(Checker, Value)
  State.CounterValue = Value
  refreshXml(Checker)
end

function refreshXml(Checker)
  Checker.UI.setXml("<Text position='0, -10, 0' fontSize='400' color='White'>" ..
    State.CounterValue .. "</Text>")
end

return Counter
