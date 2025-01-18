local ScriptingZoneManager = {}

local PlayerField = require('src.models.playerField')

local State
local ObjectList

function ScriptingZoneManager.StartGame(GObjectList, GState)
  ObjectList = GObjectList
  State = GState

  for _, Color in ipairs(State.SeatedPlayers) do
    createPlayerFields(Color)
  end
end

function createPlayerFields(Color)
  local Player = ObjectList.Players[Color]

  local ScriptLeft = Player.ScriptLeft
  local ScriptMiddle = Player.ScriptMiddle
  local ScriptRight = Player.ScriptRight

  PlayerField.createField(ObjectList, State, Color, ScriptLeft, true)
  PlayerField.createField(ObjectList, State, Color, ScriptMiddle, true)
  PlayerField.createField(ObjectList, State, Color, ScriptRight, false)
end

return ScriptingZoneManager
