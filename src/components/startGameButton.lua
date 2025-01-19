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

  StartGameButton.createButton({
    click_function = 'onClickStartButton',
    function_owner = self,
    label = 'Start Game',
    position = { 0, 0.5, 0 },
    scale = { 2, 2, 2 },
    rotation = { 0, 180, 0 },
    width = 2000,
    height = 500,
    font_size = 200,
    color = 'White',
    tooltip = 'Start the game with the current seated players'
  })

  -- VariantToggleButton.init(ObjectList)
end

function onClickStartButton(_, _, _)
  log('Start Game button clicked')

  State.updateValue('Started', true)
  State.updateValue('SeatedPlayers', getSeatedPlayers())

  -- ScriptingZoneManager.StartGame(ObjectList)
  -- CounterManager.StartGame(ObjectList)
end

return StartGameButton
