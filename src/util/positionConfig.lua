--- Position Configuration
--- Defines all positioning constants and calculations for game objects
local GuidList = require('src.util.guidList')

local PositionConfig = {}

--- Gets the current table dimensions
--- @return number, number Table width and depth scale factors
local function getTableDimensions()
  -- Use the table surface object directly by GUID (4ee1f2)
  local tableSurface = getObjectFromGUID('4ee1f2')
  if not tableSurface then
    return 1.0, 1.0
  end
  
  local tableScale = tableSurface.getScale()
  -- Table surface scale is {width, 1, depth} where:
  -- width = X scale (horizontal/left-right)
  -- depth = Z scale (forward-back)
  local width = tableScale.x
  local depth = tableScale.z
  
  -- Verify we got valid values
  if not width or not depth or width <= 0 or depth <= 0 then
    log('WARNING: Invalid table scale values (width=' .. tostring(width) .. ', depth=' .. tostring(depth) .. '), using default 1.0')
    return 1.0, 1.0
  end
  
  return width, depth
end

--- Calculates scale factors based on table size
--- Standard TTS table is 1.0x1.0, cards are typically sized for this
--- We'll use the average of width and depth to maintain proportions
--- @return number Scale factor for fields and other elements
local function calculateScaleFactor()
  local width, depth = getTableDimensions()
  -- Use average of width and depth to maintain square proportions
  -- This ensures fields scale proportionally regardless of table shape
  local avgScale = (width + depth) / 2.0
  
  -- For a standard 1.0x1.0 table, this returns 1.0
  -- For larger tables, this scales proportionally
  return avgScale
end

--- Hand positioning configuration
PositionConfig.Hands = {
  -- Scale for all hand zones
  scale = Vector(30, 5, 10),
  
  -- Position offsets relative to center
  positions = {
    Orange = Vector(0, 3, -65),
    White = Vector(-50, 3, -65),  -- Orange + left offset
    Green = Vector(50, 3, -65),   -- Orange + right offset
    Yellow = Vector(86, 3, -10),
    Red = Vector(86, 3, 35),      -- Yellow + forward offset
    Pink = Vector(-86, 3, -10),
    Purple = Vector(-86, 3, 35)   -- Pink + forward offset
  },
  
  -- Rotation offsets relative to center
  rotations = {
    Orange = Vector(0, 0, 0),
    White = Vector(0, 0, 0),
    Green = Vector(0, 0, 0),
    Yellow = Vector(0, -90, 0),
    Red = Vector(0, -90, 0),
    Pink = Vector(0, 90, 0),
    Purple = Vector(0, 90, 0)
  }
}

--- Field positioning configuration relative to player hand zones
PositionConfig.Fields = {
  -- Scale for all fields
  scale = Vector(1, 1, 1),
  
  -- Y offset for all fields
  yOffset = -3,
  
  -- Position vectors by player location (relative to hand)
  layouts = {
    -- Bottom players (White, Green, Orange)
    bottom = {
      left = Vector(-10, -3, 15),
      middle = Vector(0, -3, 15),
      right = Vector(10, -3, 15)
    },
    -- Left side players (Purple, Pink)
    left = {
      left = Vector(15, -3, 10),
      middle = Vector(15, -3, 0),
      right = Vector(15, -3, -10)
    },
    -- Right side players (Yellow, Red)
    right = {
      left = Vector(-15, -3, -10),
      middle = Vector(-15, -3, 0),
      right = Vector(-15, -3, 10)
    }
  }
}

--- Card scaling configuration
PositionConfig.Cards = {
  -- Scale factor for cards (calculated based on table size)
  -- Cards should be manually scaled ONCE in TTS to match this value
  -- After scaling cards manually, this value should match the table scale
  getScale = function()
    local scaleFactor = calculateScaleFactor()
    -- Cards should scale with the table
    -- Standard card scale is 1.0 for a 1.0x1.0 table
    return scaleFactor
  end,
  
  -- Instructions for manual card scaling:
  -- 1. Get the scale factor by calling PositionConfig.Cards.getScale()
  -- 2. In TTS, select all card objects (bean decks)
  -- 3. Set their scale to this value (e.g., if scaleFactor is 1.2, set scale to 1.2)
  -- 4. Save the game - cards will now be properly scaled
}

--- Gets the field layout for a specific color
--- @param color string The player color
--- @return table The field layout vectors for this color
function PositionConfig.getFieldLayout(color)
  if color == 'White' or color == 'Green' or color == 'Orange' then
    return PositionConfig.Fields.layouts.bottom
  elseif color == 'Purple' or color == 'Pink' then
    return PositionConfig.Fields.layouts.left
  else  -- Yellow, Red
    return PositionConfig.Fields.layouts.right
  end
end

--- Bean deck positioning
PositionConfig.BeanDecks = {
  -- Starting X position (leftmost deck)
  startX = -40,
  -- Spacing between decks
  spacing = 8,
  -- Y offset (height above table)
  yOffset = 1,
  -- Z offset (forward/back from center)
  zOffset = 50,
  -- Rotation offset from center
  rotation = Vector(0, 180, 0)
}

--- Rules positioning
PositionConfig.Rules = {
  position = Vector(0, 30, 80),
  rotation = Vector(60.43, 180, 0)
}

PositionConfig.ScoreBags = {
  -- Scale for all score bags
  scale = Vector(1, 1, 1)
}

--- Center snap points for draw/discard
PositionConfig.CenterSnapPoints = {
  { position = { -6, 0, 0 }, rotation = { 0, 180, 0 }, rotation_snap = true },
  { position = { 6, 0, 0 },  rotation = { 0, 180, 0 }, rotation_snap = true }
}

--- Gets the recommended card scale for manual scaling
--- Call this function from TTS console to get the scale value
--- Then manually scale all card objects (bean decks) to this value in TTS
--- @return number The scale factor to apply to cards
function PositionConfig.getCardScale()
  local scale = PositionConfig.Cards.getScale()
  return scale
end

--- Gets the current table dimensions (for debugging)
--- @return number, number Table width and depth
function PositionConfig.getTableDimensions()
  return getTableDimensions()
end

return PositionConfig

