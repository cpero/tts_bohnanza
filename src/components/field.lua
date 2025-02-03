local Functions       = require('Bohnanza.src.util.functions')
local Constants       = require('Bohnanza.src.util.constants')
local GuidList        = require('Bohnanza.src.util.guidList')

local LockeFieldColor = "#1F1F1F"

local State           = {
  Unlocked = false,
  Role = '',
  Color = ''
}

function onLoad(script_state)
  if script_state ~= '' then
    State = JSON.decode(script_state)
    createField()
  else
    initializeField()
  end
end

function onSave()
  if Constants.DEBUG then
    return ''
  else
    return JSON.encode(State)
  end
end

function initializeField()
  local PlayerColor = Functions.findPlayerColorFromGuid(self.guid)

  State.Role = Functions.findRoleFromGuid(self.guid)
  State.Color = PlayerColor

  if #getSeatedPlayers() > 3 then
    if State.Role == 'Right' then
      State.Unlocked = false
    else
      State.Unlocked = true
    end
  else
    State.Unlocked = true
  end

  createField()
end

function createField()
  if State.Unlocked then
    createUnlockedField()
  else
    self.UI.setXml(lockedPanelXml())
    self.createButton({
      click_function = 'onClickUnlock',
      function_owner = self,
      label = 'Unlock Field',
      width = 600,
      height = 100,
      position = { 0, 0, 0 },
    })
  end
end

function createUnlockedField()
  self.UI.setXml(unlockedPanelXml())
  self.setSnapPoints({
    {
      position = { 0, 0, 0 },
      rotation = { 0, 0, 0 },
      rotation_snap = true
    },
  })
  updateZone()
end

---Creates the XML for an unlocked field panel.
---@return string
function unlockedPanelXml()
  return "<Panel position='0, 15, 0' height='130' width='110' color='" ..
      Constants.UnlockedFieldColors[State.Color] .. "'></Panel>"
end

---Creates the XML for a locked field panel.
---@return string
function lockedPanelXml()
  return "<Panel height='130' width='110' color='" ..
      LockeFieldColor .. "' position='0, 15, 0'></Panel>"
end

function onClickUnlock(_, ClickedColor)
  if State.Color == ClickedColor then
    ---@diagnostic disable-next-line: param-type-mismatch
    broadcastToAll(State.Color .. " has unlocked their third field!", State.Color)

    self.clearButtons()
    createUnlockedField()
    State.Unlocked = true
  end
end

function onObjectEnterZone(Zone, Object)
  if Zone.getGUID() == self.guid and (Object.type == 'Card' or Object.type == 'Deck') then
    updateZone()
  end
end

function onObjectLeaveZone(Zone, Object)
  if Zone.getGUID() == self.guid and (Object.type == 'Card' or Object.type == 'Deck') then
    updateZone()
  end
end

function updateZone()
  if State.Unlocked then
    local FieldCounter = getObjectFromGUID(GuidList.Players[State.Color]['FieldCounter' .. State.Role])
    FieldCounter.UI.setXml("<Text color='white' text='" ..
      getNumberOfCardsInZone() .. "' fontSize='100' position='0, -70, 0'/>")
  end
end

function getNumberOfCardsInZone()
  local Counter = 0
  for _, Object in ipairs(self.getObjects()) do
    if Object.type == 'Card' then
      Counter = Counter + 1
    elseif Object.type == 'Deck' then
      Counter = Counter + #Object.getObjects()
    end
  end

  return Counter
end
