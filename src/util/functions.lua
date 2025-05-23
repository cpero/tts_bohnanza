local Functions = {}

local GuidList = require('Bohnanza.src.util.guidList')
local Constants = require('Bohnanza.src.util.constants')

function Functions.findPlayerColorFromGuid(Guid)
  local color = nil
  for Color, Zones in pairs(GuidList.Players) do
    if Color ~= nil then
      for _, ZoneGuid in pairs(Zones) do
        if ZoneGuid == Guid then
          color = Color
        end
      end
    end
  end
  return color
end

function Functions.findRoleFromGuid(Guid)
  local position = nil
  for _, Zones in pairs(GuidList.Players) do
    if Zones.FieldLeft == Guid then
      position = 'Left'
    elseif Zones.FieldMiddle == Guid then
      position = 'Middle'
    elseif Zones.FieldRight == Guid then
      position = 'Right'
    end
  end
  return position
end

function Functions.allButCurrentPlayer(playerColor)
  local players = {}

  for _, color in ipairs(Constants.AvailableColors) do
    if color ~= playerColor then
      table.insert(players, color)
    end
  end
  return players
end

return Functions
