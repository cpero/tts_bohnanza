local ScriptingZones = {}

Functions = require('src.util.functions')

local State
local ObjectList

local UnlockeFieldColor = "#1F2433"
local LockeFieldColor = "#320B0B"

function ScriptingZones.initCounters(GObjectList, GState)
  ObjectList = GObjectList
  State = GState

  for _, Player in pairs(ObjectList.Players) do
    -- Player.ScriptLeft.spawnObject({
    --   type = 'Checker_black',
    --   position = { 0, -1, -10 },
    --   scale = { 2, 2, 2 },
    -- })
  end
end

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
  ScriptingZone.setPosition(ScriptingZone.getPosition() + vector(0, 0.1, 0))
  if IsUnlocked then
    -- ScriptingZone.UI.setXml(unlockedPanelXml(ScriptingZone.getGUID()))
    -- ScriptingZone.setSnapPoints({
    --   {
    --     position = { 0, 0, 0.4 },
    --     rotation = { 0, 0, 0 },
    --     rotation_snap = true
    --   },
    -- })
  else
    ScriptingZone.UI.setXml(lockedPanelXml())
    ScriptingZone.createButton({
      click_function = 'onClickUnlock',
      label = 'Unlock Field',
      width = 700,
      height = 100,
      position = { 0, 0, 1.25 },
    })
  end
end

function unlockedPanelXml(ScriptingZoneGuid)
  return "<Panel position='0, 0, 0' height='350' width='175'><InputField position='0, -100, -10' id='" ..
      ScriptingZoneGuid ..
      "_fieldCounter' color='White' fontSize='20'>0</InputField><Panel color='" ..
      UnlockeFieldColor .. "'></Panel></Panel>"
end

function lockedPanelXml()
  return "<Panel height='350' width='175' color='" ..
      LockeFieldColor .. "' position='0 0 -1'></Panel>"
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
