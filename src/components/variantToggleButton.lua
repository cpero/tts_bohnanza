local VariantToggleButton = {}

local Constants = require('src.util.constants')
local Functions = require('src.util.functions')
local State = require('src.models.state')
local GuidList = require('src.util.guidList')


function VariantToggleButton.init()
  local VariantToggleButton = State.getObjectList().Buttons.VariantToggle
  local Table = State.getObjectList().Table

  VariantToggleButton.setName('Variant Toggle Button')
  VariantToggleButton.locked = true
  VariantToggleButton.interactable = false
  VariantToggleButton.setPosition(Table.getPosition() + Vector(0, 1, 0))

  createVariantButton()
end

function onPlayerChangeColor(player_color)
  createVariantButton()
end

function createVariantButton()
  local VariantToggleButton = getObjectFromGUID(GuidList.Buttons.VariantToggle)
  VariantToggleButton.UI.setXml([[
    <VerticalLayout id="VariantSection" position="0, -100, -10"  height="1700" width="2000" spacing="150">
        <Button id="VariantToggleButton" color="Red" text="Enable Variant Mode?" textColor="Black" fontSize="100" onClick="onClickVariantToggleButton" scale="2,2,2" rotation="0, 0, 0" />
        <Text id="VariantStatus" fontSize="150" color="White" text="Current Status: Disabled" />
        <Text fontSize="100" color="White">Adds Cocoa, Wax, and Coffee beans to the deck.</Text>
        <Text fontSize="100" color="White">Required for 6+ players.</Text>
    </VerticalLayout>
  ]])

  Wait.frames(function()
    local NumPlayers = Functions.length(getSeatedPlayers())
    if NumPlayers >= 6 then
      VariantToggleButton.UI.setAttributes('VariantToggleButton', {
        color = 'Green',
        textColor = 'Black',
        interactable = 'false',
        text = 'Variant Mode Required for 6+ Players'
      })
      VariantToggleButton.UI.setAttribute('VariantToggleButton', 'color', 'Green')
      VariantToggleButton.UI.setAttribute('VariantToggleButton', 'textColor', 'Black')
      VariantToggleButton.UI.setAttribute('VariantToggleButton', 'interactable', 'false')
      VariantToggleButton.UI.setAttribute('VariantToggleButton', 'text', 'Variant Mode Required for 6+ Players')
      VariantToggleButton.UI.setAttribute('VariantStatus', 'text', "Current status: Enabled")
    end
  end, 20)
end

function onClickVariantToggleButton(_, _, _)
  local IsEnabled = not State.getState().Variant
  State.updateValue('Variant', IsEnabled)

  local toggleButton = getObjectFromGUID(GuidList.Buttons.VariantToggle)

  toggleButton.UI.setAttribute('VariantToggleButton', 'color', IsEnabled and 'Green' or 'Red')
  toggleButton.UI.setAttribute('VariantToggleButton', 'textColor', IsEnabled and 'Black' or 'White')
  toggleButton.UI.setAttribute('VariantStatus', 'text', "Current status: " .. (IsEnabled and 'Enabled' or 'Disabled'))
end

return VariantToggleButton
