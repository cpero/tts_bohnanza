local Counters = {}

local Constants = require('src.util.constants')

local ObjectList
local State

function Counters.StartGame(GObjectList, GState)
  ObjectList = GObjectList
  State = GState

  log('Spawning initial counters')
  State.Counters = {}
  for _, Color in pairs(State.SeatedPlayers) do
    State.Counters[Color] = {}

    local Player = ObjectList.Players[Color]
    spawnInitCounter(Color, Player.ScriptLeft)
    spawnInitCounter(Color, Player.ScriptMiddle)
    spawnInitCounter(Color, Player.ScriptRight)
  end
end

function spawnInitCounter(Color, ScriptingZone)
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

  updateCheckerValue(Color, Checker, 0)
end

function updateCheckerValue(Color, Checker, Value)
  State.Counters[Color][Checker.getGUID()] = Value
  updateCheckerXml(Color, Checker)
end

function updateCheckerXml(Color, Checker)
  Checker.UI.setXml(checkerXml(Color, Checker))
end

function checkerXml(Color, Checker)
  return "<Text position='0, -10, 0' fontSize='400' color='White'>" ..
      State.Counters[Color][Checker.getGUID()] .. "</Text>"
end

return Counters
