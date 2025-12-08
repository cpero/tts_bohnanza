--- Field Parser Utility
--- Handles parsing of field object names to extract color and position
local FieldParser = {}

--- Extracts the player color from a field object name
--- @param fieldName string The name of the field object (e.g., "YellowLeftField")
--- @return string The extracted color (e.g., "Yellow")
function FieldParser.extractColor(fieldName)
  if not fieldName or fieldName == '' then
    error('Field name cannot be empty')
  end
  
  local color = fieldName
  color = string.gsub(color, 'LeftField', '')
  color = string.gsub(color, 'MiddleField', '')
  color = string.gsub(color, 'RightField', '')
  
  if color == fieldName then
    error('Invalid field name format: ' .. fieldName)
  end
  
  return color
end

--- Extracts the position from a field object name
--- @param fieldName string The name of the field object (e.g., "YellowLeftField")
--- @param color string The player color already extracted
--- @return string The position ("Left", "Middle", or "Right")
function FieldParser.extractPosition(fieldName, color)
  if not fieldName or fieldName == '' then
    error('Field name cannot be empty')
  end
  
  local position = fieldName
  position = string.gsub(position, 'Field', '')
  position = string.gsub(position, color, '')
  
  if position ~= 'Left' and position ~= 'Middle' and position ~= 'Right' then
    error('Invalid field position: ' .. position)
  end
  
  return position
end

--- Parses a field object name and returns both color and position
--- @param fieldName string The name of the field object
--- @return table A table containing color and position keys
function FieldParser.parse(fieldName)
  local color = FieldParser.extractColor(fieldName)
  local position = FieldParser.extractPosition(fieldName, color)
  
  return {
    color = color,
    position = position
  }
end

return FieldParser

