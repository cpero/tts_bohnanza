--- Position Configuration
--- Defines all positioning constants and calculations for game objects
local PositionConfig = {}

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

--- Center snap points for draw/discard
PositionConfig.CenterSnapPoints = {
  { position = { -6, 0, 0 }, rotation = { 0, 180, 0 }, rotation_snap = true },
  { position = { 6, 0, 0 },  rotation = { 0, 180, 0 }, rotation_snap = true }
}

return PositionConfig

