--- Field Component
--- Manages a single bean field for a player
--- Handles field locking/unlocking and player-specific interactions

local Constants = require('src.util.constants')
local FieldParser = require('src.util.fieldParser')
local FieldState = require('src.util.fieldState')
local FieldUI = require('src.util.fieldUI')

-- Component state
local state = nil

--- Initializes the field component when loaded
--- @param script_state string JSON-encoded state from previous session
function onLoad(script_state)
  -- Try to load existing state
  state = FieldState.fromJSON(script_state)
  
  -- Initialize new field if no saved state exists
  if not state or not state:isInitialized() then
    initializeField()
  end
end

--- Initializes a new field from the object's name
function initializeField()
  local fieldName = self.getName()
  
  -- Parse the field name to extract color and position
  local parsed = FieldParser.parse(fieldName)
  
  -- Determine if this field should start locked (Right fields start locked)
  local shouldLock = (parsed.position == 'Right')
  
  -- Create new state
  state = FieldState.new(parsed.color, parsed.position, shouldLock)
  
  -- Configure UI based on lock state
  if shouldLock then
    FieldUI.setupLockedField(self)
  else
    unlockField()
  end
end

--- Saves the field state when the game is saved
--- @return string JSON-encoded state (empty in debug mode)
function onSave()
  if not state then
    return ''
  end
  
  return state:toJSON(Constants.DEBUG)
end

--- Handles click events on the unlock field button
--- @param player table The player who clicked the button
function onClickUnlockField(player)
  if not state then
    log('ERROR: Field state not initialized')
    return
  end
  
  -- Check if the player owns this field
  if player.color ~= state:getColor() then
    broadcastToColor(
      'You cannot unlock a field that is not yours.',
      player.color,
      { r = 1, g = 0, b = 0 }
    )
    return
  end
  
  -- Unlock the field
  unlockField()
end

--- Unlocks the field and updates UI/snap points
function unlockField()
  if not state then
    log('ERROR: Field state not initialized')
    return
  end
  
  -- Update state
  state:unlock()
  
  -- Update UI
  FieldUI.setupUnlockedField(self, state:getColor())
  FieldUI.setupSnapPoints(self)
end

--- Gets the current field state (for debugging/testing)
--- @return table The current field state
function getFieldState()
  return state
end
