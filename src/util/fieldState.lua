--- Field State Manager
--- Manages the state of a single field component
local FieldState = {}
FieldState.__index = FieldState

--- Creates a new FieldState instance
--- @param color string The player color for this field
--- @param position string The position ("Left", "Middle", "Right")
--- @param locked boolean Whether the field is initially locked
--- @return table A new FieldState instance
function FieldState.new(color, position, locked)
  local self = setmetatable({}, FieldState)
  self.init = true
  self.color = color or ''
  self.position = position or ''
  self.locked = locked or false
  return self
end

--- Creates a FieldState from a saved JSON string
--- @param jsonString string The JSON-encoded state
--- @return table A FieldState instance
function FieldState.fromJSON(jsonString)
  if not jsonString or jsonString == '' then
    return nil
  end
  
  local decoded = JSON.decode(jsonString)
  local self = setmetatable({}, FieldState)
  self.init = decoded.init or false
  self.color = decoded.color or ''
  self.position = decoded.position or ''
  self.locked = decoded.locked or false
  return self
end

--- Converts the state to a JSON string
--- @param debug boolean If true, returns empty string (no save in debug mode)
--- @return string JSON-encoded state
function FieldState:toJSON(debug)
  if debug then
    return ''
  end
  
  return JSON.encode({
    init = self.init,
    color = self.color,
    position = self.position,
    locked = self.locked
  })
end

--- Unlocks the field
function FieldState:unlock()
  self.locked = false
end

--- Checks if the field is locked
--- @return boolean True if locked
function FieldState:isLocked()
  return self.locked
end

--- Checks if the field is initialized
--- @return boolean True if initialized
function FieldState:isInitialized()
  return self.init
end

--- Gets the player color
--- @return string The player color
function FieldState:getColor()
  return self.color
end

--- Gets the field position
--- @return string The field position
function FieldState:getPosition()
  return self.position
end

return FieldState

