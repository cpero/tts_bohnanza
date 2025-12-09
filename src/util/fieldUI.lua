--- Field UI Manager
--- Handles UI updates for field components
local Constants = require('src.util.constants')

local FieldUI = {}

--- Updates the field color in the UI
--- @param object table The TTS object with UI
--- @param color string The color to set (hex format)
function FieldUI.setFieldColor(object, color)
  if not object or not object.UI then
    error('Invalid object or missing UI')
  end
  
  object.UI.setAttribute('field', 'color', color)
end

--- Shows or hides the unlock button
--- @param object table The TTS object with UI
--- @param active boolean Whether the button should be active
function FieldUI.setUnlockButtonActive(object, active)
  if not object or not object.UI then
    error('Invalid object or missing UI')
  end
  
  object.UI.setAttribute('unlockFieldBtn', 'active', active)
end

--- Configures the field UI for a locked state
--- @param object table The TTS object with UI
function FieldUI.setupLockedField(object)
  FieldUI.setFieldColor(object, Constants.LockedFieldColor)
  FieldUI.setUnlockButtonActive(object, true)
end

--- Configures the field UI for an unlocked state
--- @param object table The TTS object with UI
--- @param color string The player color
function FieldUI.setupUnlockedField(object, color)
  if not Constants.UnlockedFieldColors[color] then
    error('Invalid color: ' .. tostring(color))
  end
  
  FieldUI.setFieldColor(object, Constants.UnlockedFieldColors[color])
  FieldUI.setUnlockButtonActive(object, false)
end

--- Sets up snap points for an unlocked field
--- @param object table The TTS object
function FieldUI.setupSnapPoints(object)
  if not object then
    error('Invalid object')
  end
  
  -- Verify object is still valid and accessible
  local pos = object.getPosition()
  if not pos then
    log('WARNING: Cannot set snap points - object position not accessible')
    return
  end
  
  -- Set snap point with 180 degree Y rotation to make cards face the player
  -- This matches the center snap points configuration
  -- Note: In TTS, snap point rotations are relative to the object's rotation
  object.setSnapPoints({
    { position = { 0, 0, 0 }, rotation = { 0, 180, 0 }, rotation_snap = true }
  })
end

return FieldUI

