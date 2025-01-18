local PlayerField = {}

local Constants = require('src.util.constants')
local LockeFieldColor = "#1F1F1F"

local ObjectList
local State

function PlayerField.createField(GObjectList, GState, Color, ScriptingZone, IsUnlocked)
  ObjectList = GObjectList
  State = GState
  ScriptingZone.setPosition(ScriptingZone.getPosition() + vector(0, 0.1, 0))
  if IsUnlocked then
    ScriptingZone.UI.setXml(unlockedPanelXml(Color))
    ScriptingZone.setSnapPoints({
      {
        position = { 0, 1, 0 },
        rotation = { 0, 0, 0 },
        rotation_snap = true
      },
    })
  else
    ScriptingZone.UI.setXml(lockedPanelXml())
    ScriptingZone.createButton({
      click_function = 'onClickUnlock',
      label = 'Unlock Field',
      width = 700,
      height = 100,
      position = { 0, 0, 0 },
    })
  end
end

function unlockedPanelXml(Color)
  return "<Panel position='0, 8, 0' height='290' width='200' color='" ..
      Constants.UnlockedFieldColors[Color] .. "'></Panel>"
end

function lockedPanelXml()
  return "<Panel height='290' width='200' color='" ..
      LockeFieldColor .. "' position='0, 9, 0'></Panel>"
end

function onClickUnlock(ScriptingZoneEl, _, _)
  local Color = findColorFromScriptingZone(ScriptingZoneEl.getGUID())
  log('Unlocking panel for ' .. Color)
  broadcastToAll(Color .. " has unlocked their third field!", Color)

  ScriptingZoneEl.clearButtons()
  createPanelUI(Color, ScriptingZoneEl, true)
end

return PlayerField
