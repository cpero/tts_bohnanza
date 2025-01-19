local ScriptingZoneManager = {}

local PlayerField = require('src.models.playerField')
local Functions = require('src.util.functions')
local State = require('src.models.state')

function ScriptingZoneManager.StartGame()
  for _, Color in ipairs(State.getState().SeatedPlayers) do
    createPlayerFields(Color)
  end
end

function createPlayerFields(Color)
  local Player = State.getObjectList().Players[Color]

  local ScriptLeft = Player.ScriptLeft
  local ScriptMiddle = Player.ScriptMiddle
  local ScriptRight = Player.ScriptRight

  PlayerField.createField(Color, ScriptLeft, true)
  PlayerField.createField(Color, ScriptMiddle, true)
  PlayerField.createField(Color, ScriptRight, Functions.length(State.getState().SeatedPlayers) < 4)
end

return ScriptingZoneManager
