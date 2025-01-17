local ScriptingZones = {}

local State
local ObjectList

local Green = "#ACD8AA"
local Red = "#E78F8E"

function ScriptingZones.StartGame(GObjectList, GState)
  ObjectList = GObjectList
  State = GState

  for _, Color in ipairs(State.SeatedPlayers) do
    ScriptingZones.showPanels(Color)
  end
end

function ScriptingZones.showPanels(Color)
  local Player = ObjectList.Players[Color]

  local ScriptLeft = Player.ScriptLeft
  local ScriptMiddle = Player.ScriptMiddle
  local ScriptRight = Player.ScriptRight

  ScriptingZones.createPanelUI(ScriptLeft, true)
  ScriptingZones.createPanelUI(ScriptMiddle, true)
  ScriptingZones.createPanelUI(ScriptRight, false)
end

function ScriptingZones.createPanelUI(ScriptingZone, IsUnlocked)
  if IsUnlocked then
    ScriptingZone.UI.setXml(unlockedPanelXml())
  else
    ScriptingZone.UI.setXml(lockedPanelXml())
    ScriptingZone.createButton({
      click_function = 'onClickUnlock',
      label = 'Unlock Field',
      tooltip = 'Changes field color to green',
      width = 1000,
      height = 100,
      position = { 0, 1, -2 },
    })
  end
end

function unlockedPanelXml()
  return "<Panel height='350' width='175' color='" .. Green .. "' position='0 0 -1'></Panel>"
end

function lockedPanelXml()
  return "<Panel height='350' width='175' color='" ..
      Red .. "' position='0 0 -1'></Panel>"
end

function onClickUnlock(ScriptingZoneEl, _, _)
  local Color = findColorFromScriptingZone(ScriptingZoneEl.getGUID())
  log('Unlocking panel for ' .. Color)
  broadcastToAll(Color .. " has unlocked their third field!", Color)

  ScriptingZoneEl.clearButtons()
  ScriptingZones.createPanelUI(ScriptingZoneEl, true)
end

function findColorFromScriptingZone(ScriptingZoneGuid)
  for Color, Player in pairs(ObjectList.Players) do
    if Player.ScriptRight.getGUID() == ScriptingZoneGuid then
      return Color
    end
  end
end

return ScriptingZones
