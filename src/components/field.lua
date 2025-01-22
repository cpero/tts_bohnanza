local Functions = require('Bohnanza.src.util.functions')
local Constants = require('Bohnanza.src.util.constants')

local LockeFieldColor = "#1F1F1F"

local State = {
  Unlocked = false,
  Role = '',
  Color = ''
}

function onLoad(script_state)
  if script_state ~= '' then
    State = JSON.decode(script_state)
  end

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

  -- createField(PlayerColor)
end

function onSave()
  if Constants.DEBUG then
    return ''
  else
    return JSON.encode(State)
  end
end

function createField(Color)
  if State.Unlocked then
    createUnlockedField(Color)
  else
    self.UI.setXml(lockedPanelXml())
    self.createButton({
      click_function = 'onClickUnlock',
      function_owner = self,
      label = 'Unlock Field',
      width = 700,
      height = 100,
      position = { 0, 0, 0 },
    })
  end
end

function createUnlockedField(Color)
  self.UI.setXml(unlockedPanelXml(Color))
  self.setSnapPoints({
    {
      position = { 0, 0, 0 },
      rotation = { 0, 0, 0 },
      rotation_snap = true
    },
  })
end

---Creates the XML for an unlocked field panel.
---@param Color string
---@return string
function unlockedPanelXml(Color)
  return "<Panel position='0, 15, 0' height='120' width='100' color='" ..
      Constants.UnlockedFieldColors[Color] .. "'></Panel>"
end

---Creates the XML for a locked field panel.
---@return string
function lockedPanelXml()
  return "<Panel height='120' width='100' color='" ..
      LockeFieldColor .. "' position='0, 15, 0'></Panel>"
end

function onClickUnlock(_, ClickedColor)
  if State.Color == ClickedColor then
    broadcastToAll(State.Color .. " has unlocked their third field!", State.Color)

    self.clearButtons()
    createUnlockedField(State.Color)
  end
end
