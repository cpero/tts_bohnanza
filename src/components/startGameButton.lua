local StartGameButton = {}

local Constants = require('src.util.constants')
local Functions = require('src.util.functions')
local ScriptingZoneManager = require('src.managers.scriptingZoneManager')
local CounterManager = require('src.managers.counterManager')
local VariantToggleButton = require('src.components.variantToggleButton')
local GuidList = require('src.util.guidList')

local State = {
  Init = false,
  Started = false,
  Variant = false
}

function init()
  log('Creating Start Game button')

  local StartGameButton = getObjectFromGUID(GuidList.Buttons.StartGame)
  local Table = getObjectFromGUID(GuidList.Table)

  -- log(State)

  if not State.Init then
    StartGameButton.setName('Start Game Button')
    StartGameButton.locked = true
    StartGameButton.interactable = false
    StartGameButton.setPosition(Table.getPosition() + Vector(0, 1, 30))

    State.Init = true

    StartGameButton.UI.setXml([[
      <Button id="StartGameButton" height="500" width="2000" color="White"
        text="Start Game" textColor="Black" fontSize="300" onClick="onClickStartButton"
        position="0, -100, 0" scale="2,2,2" rotation="0, 0, 0" />
    ]])

    VariantToggleButton.init()
  end
end

function onClickStartButton(_, _, _)
  log('Start Game button clicked')

  State.started = true

  Wait.frames(function()
    if Functions.length(getSeatedPlayers()) < 2 then
      broadcastToAll('Must have at least 2 players to start the game.', Constants.ColorRed)
      return
    end

    local StartGameButton = getObjectFromGUID(GuidList.Buttons.StartGame)
    local VariantToggleButtonEl = getObjectFromGUID(GuidList.Buttons.VariantToggle)

    State.Started = true
    local isEnabled = VariantToggleButton.isEnabled()
    log(isEnabled)
    -- State.Variant = VariantToggleButton.isEnabled()
    log(State)

    -- ScriptingZoneManager.StartGame()
    -- CounterManager.StartGame()

    StartGameButton.UI.setAttribute('StartGameButton', 'active', 'false')
    VariantToggleButtonEl.UI.setAttribute('VariantSection', 'active', 'false')
  end, 5)
end

function onSave()
  log(State)

  -- return JSON.encode(State)
  return ''
end

function onLoad(save_state)
  log(save_state)
  if save_state ~= '' then
    State = JSON.decode(save_state)
  end

  init()
end

return StartGameButton
