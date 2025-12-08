--- Utility Functions
--- Common helper functions used throughout the mod

local GuidList = require('src.util.guidList')
local Constants = require('src.util.constants')

local Functions = {}

--- Finds the player color associated with a given GUID
--- @param guid string The GUID to search for
--- @return string|nil The player color, or nil if not found
function Functions.findPlayerColorFromGuid(guid)
  if not guid or guid == '' then
    log('WARNING: Invalid GUID provided to findPlayerColorFromGuid')
    return nil
  end
  
  for color, zones in pairs(GuidList.Players) do
    if color ~= nil then
      for _, zoneGuid in pairs(zones) do
        if zoneGuid == guid then
          return color
        end
      end
    end
  end
  
  return nil
end

--- Finds the field position (Left/Middle/Right) for a given GUID
--- @param guid string The GUID to search for
--- @return string|nil The position name, or nil if not found
function Functions.findRoleFromGuid(guid)
  if not guid or guid == '' then
    log('WARNING: Invalid GUID provided to findRoleFromGuid')
    return nil
  end
  
  for _, zones in pairs(GuidList.Players) do
    if zones.LeftField == guid then
      return 'Left'
    elseif zones.MiddleField == guid then
      return 'Middle'
    elseif zones.RightField == guid then
      return 'Right'
    end
  end
  
  return nil
end

--- Returns a list of all player colors except the specified one
--- Used for hiding/showing objects to specific players
--- @param playerColor string The color to exclude from the list
--- @return table Array of color strings
function Functions.allButCurrentPlayer(playerColor)
  local players = {}
  
  for _, color in ipairs(Constants.AvailableColors) do
    if color ~= playerColor then
      table.insert(players, color)
    end
  end
  
  return players
end

--- Validates if a color is a valid player color
--- @param color string The color to validate
--- @return boolean True if the color is valid
function Functions.isValidColor(color)
  for _, validColor in ipairs(Constants.AvailableColors) do
    if validColor == color then
      return true
    end
  end
  return false
end

--- Gets a player object by color with error handling
--- @param color string The player color
--- @return table|nil The player object data, or nil if not found
function Functions.getPlayerByColor(color)
  if not Functions.isValidColor(color) then
    log('ERROR: Invalid color: ' .. tostring(color))
    return nil
  end
  
  return GuidList.Players[color]
end

--- Safely gets an object by GUID with error logging
--- @param guid string The GUID to retrieve
--- @param objectName string Optional name for error logging
--- @return table|nil The object, or nil if not found
function Functions.safeGetObject(guid, objectName)
  if not guid or guid == '' then
    log('ERROR: Invalid GUID provided' .. (objectName and ' for ' .. objectName or ''))
    return nil
  end
  
  local obj = getObjectFromGUID(guid)
  if not obj then
    log('WARNING: Object not found with GUID: ' .. guid .. (objectName and ' (' .. objectName .. ')' or ''))
  end
  
  return obj
end

--- Broadcasts a message to all players
--- @param message string The message to broadcast
--- @param color table Optional RGB color table {r, g, b}
function Functions.broadcastToAll(message, color)
  color = color or { r = 1, g = 1, b = 1 }
  broadcastToAll(message, color)
end

--- Broadcasts an error message to all players in red
--- @param message string The error message
function Functions.broadcastError(message)
  Functions.broadcastToAll('ERROR: ' .. message, { r = 1, g = 0, b = 0 })
end

--- Broadcasts a warning message to all players in yellow
--- @param message string The warning message
function Functions.broadcastWarning(message)
  Functions.broadcastToAll('WARNING: ' .. message, { r = 1, g = 1, b = 0 })
end

--- Broadcasts a success message to all players in green
--- @param message string The success message
function Functions.broadcastSuccess(message)
  Functions.broadcastToAll(message, { r = 0, g = 1, b = 0 })
end

return Functions
