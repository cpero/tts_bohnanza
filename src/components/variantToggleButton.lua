local VariantToggleButton = {}

local Constants = require('src.util.constants')
local Functions = require('src.util.functions')
local GuidList = require('src.util.guidList')

local State = {
  Variant = false
}


function VariantToggleButton.init()
  local VariantToggleButton = getObjectFromGUID(GuidList.Buttons.VariantToggle)
  local Table = getObjectFromGUID(GuidList.Table)

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
  local StartGameButton = getObjectFromGUID(GuidList.Buttons.StartGame)

  Wait.frames(function()
    if StartGameButton.UI.getAttribute('StartGameButton', 'active') == 'false' then
      return
    end

    local NumPlayers = Functions.length(getSeatedPlayers())
    if NumPlayers >= 6 then
      VariantToggleButton.UI.setXml([[
        <VerticalLayout id="VariantSection" position="0, -100, -10"  height="1700" width="2000" spacing="150">
            <Button id="VariantToggleButton" color="Green" text="Variant Mode Required for 6+ Players" textColor="White" fontSize="100" onClick="onClickVariantToggleButton" scale="2,2,2" rotation="0, 0, 0" interactable="false" />
            <Text id="VariantStatus" fontSize="150" color="White" text="Enabled" />
            <Text fontSize="100" color="White">Adds Cocoa, Wax, and Coffee beans to the deck.</Text>
            <Text fontSize="100" color="White">Required for 6+ players.</Text>
        </VerticalLayout>
      ]])
    else
      VariantToggleButton.UI.setXml([[
        <VerticalLayout id="VariantSection" position="0, -100, -10"  height="1700" width="2000" spacing="150">
            <Button id="VariantToggleButton" color="Red" text="Enable Variant Mode?" textColor="Black" fontSize="100" onClick="onClickVariantToggleButton" scale="2,2,2" rotation="0, 0, 0" />
            <Text id="VariantStatus" fontSize="150" color="White" text="Disabled" />
            <Text fontSize="100" color="White">Adds Cocoa, Wax, and Coffee beans to the deck.</Text>
            <Text fontSize="100" color="White">Required for 6+ players.</Text>
        </VerticalLayout>
      ]])
    end
  end, 5)
end

function onClickVariantToggleButton(_, _, _)
  local toggleButton = getObjectFromGUID(GuidList.Buttons.VariantToggle)

  local IsEnabled = not State.Variant
  State.Variant = IsEnabled

  toggleButton.UI.setAttribute('VariantToggleButton', 'color', IsEnabled and 'Green' or 'Red')
  toggleButton.UI.setAttribute('VariantToggleButton', 'textColor', IsEnabled and 'Black' or 'White')
  toggleButton.UI.setAttribute('VariantStatus', 'text', "Current status: " .. (IsEnabled and 'Enabled' or 'Disabled'))
end

function VariantToggleButton.isEnabled()
  local toggleButton = getObjectFromGUID(GuidList.Buttons.VariantToggle)

  local IsEnabled = toggleButton.UI.getAttribute('VariantStatus', 'text'):find('Enabled')
  return IsEnabled
end

return VariantToggleButton
