local StartGameButton = {}

local Constants = require('src.util.constants')
local Functions = require('src.util.functions')
local ScriptingZoneManager = require('src.managers.scriptingZoneManager')
local CounterManager = require('src.managers.counterManager')
local VariantToggleButton = require('src.components.variantToggleButton')
local State = require('src.models.state')

function StartGameButton.init()
  log('Creating Start Game button')

  local StartGameButton = State.getObjectList().Buttons.StartGame
  local Table = State.getObjectList().Table

  StartGameButton.setName('Start Game Button')
  StartGameButton.locked = true
  StartGameButton.interactable = false
  StartGameButton.setPosition(Table.getPosition() + Vector(0, 1, 30))

  StartGameButton.UI.setXml([[
    <Button id="StartGameButton" height="500" width="2000" color="White"
      text="Start Game" textColor="Black" fontSize="300" onClick="onClickStartButton"
      position="0, -100, 0" scale="2,2,2" rotation="0, 0, 0" />
  ]])

  VariantToggleButton.init()
end

function onClickStartButton(_, _, _)
  log('Start Game button clicked')

  State.loadObjectList()

  State.updateValue('Started', true)
  State.updateValue('SeatedPlayers', getSeatedPlayers())

  ScriptingZoneManager.StartGame()
  CounterManager.StartGame()

  local StartGameButton = State.getObjectList().Buttons.StartGame
  StartGameButton.UI.setAttribute('StartGameButton', 'active', 'false')

  local VariantToggleButton = State.getObjectList().Buttons.VariantToggle
  VariantToggleButton.UI.setAttribute('VariantSection', 'active', 'false')
end

return StartGameButton
