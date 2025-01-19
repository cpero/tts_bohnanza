local PlayerField = {}

local Constants = require('src.util.constants')
local Functions = require('src.util.functions')
local Counter = require('src.models.counter')
local State = require('src.models.state')

local LockeFieldColor = "#1F1F1F"

function PlayerField.createField(Color, ScriptingZone, IsUnlocked)
  ScriptingZone.setPosition(ScriptingZone.getPosition() + vector(0, 0.1, 0))
  if IsUnlocked then
    createUnlockedField(ScriptingZone, Color)
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

function createUnlockedField(ScriptingZone, Color)
  ScriptingZone.UI.setXml(unlockedPanelXml(Color))
  ScriptingZone.setSnapPoints({
    {
      position = { 0, 0, 0 },
      rotation = { 0, 0, 0 },
      rotation_snap = true
    },
  })
end

function unlockedPanelXml(Color)
  return "<Panel position='0, 8, 0' height='290' width='200' color='" ..
      Constants.UnlockedFieldColors[Color] .. "'></Panel>"
end

function lockedPanelXml()
  return "<Panel height='290' width='200' color='" ..
      LockeFieldColor .. "' position='0, 8, 0'></Panel>"
end

function onClickUnlock(ScriptingZoneEl, _, _)
  local Color = Functions.findColorFromObject(State.getObjectList(), ScriptingZoneEl.getGUID())
  broadcastToAll(Color .. " has unlocked their third field!", Color)

  ScriptingZoneEl.clearButtons()
  createUnlockedField(ScriptingZoneEl, Color)
end

function onObjectEnterZone(Zone, _)
  updateZone(Zone)
end

function onObjectLeaveZone(Zone, _)
  updateZone(Zone)
end

---Refreshes the counter with the number of objects in a given zone
---@param Zone table
function updateZone(Zone)
  local Color = Functions.findColorFromObject(State.getObjectList(), Zone.guid)

  if Color ~= "" and State.getState().Counters ~= {} then
    local CounterAnchor = getObjectFromGUID(State.getState().Counters[Color][Zone.guid])
    if CounterAnchor ~= nil then
      Counter.setCheckerValue(Color, CounterAnchor, getLengthOfObjectsInZone(Zone))
    end
  end
end

---Find the number of cards occupying a zone
---@param Zone table
---@return integer
function getLengthOfObjectsInZone(Zone)
  local size = 0
  for _, Object in ipairs(Zone.getObjects(true)) do
    if Object.type == "Card" then
      size = size + 1
    elseif Object.type == "Deck" then
      size = size + Functions.length(Object.getObjects())
    end
  end
  return size
end

return PlayerField
