local Counter = {}

local Constants = require('src.util.constants')

local ObjectList
local State

function Counter.createCounter(GObjectList, GState, Color, ScriptingZone)
  ObjectList = GObjectList
  State = GState
  local PositionVector

  if Color == 'Blue' then
    PositionVector = vector(-10, 0, 0)
  elseif Color == 'Purple' then
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

  Counter.setCheckerValue(Color, Checker, 0)
end

function Counter.setCheckerValue(Color, Checker, Value)
  State.Counters[Color][Checker.getGUID()] = Value
  refreshXml(Color, Checker)
end

function refreshXml(Color, Checker)
  Checker.UI.setXml("<Text position='0, -10, 0' fontSize='400' color='White'>" ..
    State.Counters[Color][Checker.getGUID()] .. "</Text>")
end

return Counter
