--- Global Script
--- Main entry point for the mod, handles initial setup

local GuidList = require('src.util.guidList')
local Constants = require('src.util.constants')
local PositionConfig = require('src.util.positionConfig')

local state = {
  stage = 1,
  seatedPlayers = {},
}

--- Called when the mod is loaded
--- @param script_state string JSON-encoded state from previous session
function onLoad(script_state)
  if script_state ~= '' then
    state = JSON.decode(script_state)
  end
  
  -- Always run setupGame in DEBUG mode to ensure fields are positioned
  -- Or run if this is the first load (stage == 1)
  if Constants.DEBUG or state.stage == 1 then
    -- Wait for all objects to load before calling setupGame
    Wait.time(function()
      local center = getObjectFromGUID(GuidList.Center)
      if center then
        center.call('setupGame')
        state.stage = 2
      end
    end, 1)
  end
end

--- Called when the game is saved
--- @return string JSON-encoded state (empty in debug mode)
function onSave()
  if Constants.DEBUG then
    return ''
  else
    return JSON.encode(state)
  end
end

--- Gets the recommended card scale for manual scaling
--- Call this from TTS console using: lua getCardScale()
--- Or: Global/call('getCardScale')
--- @return number The scale factor to apply to cards
function getCardScale()
  local success, scale, tableWidth, tableDepth = pcall(function()
    local PositionConfig = require('src.util.positionConfig')
    local scale = PositionConfig.Cards.getScale()
    local width, depth = PositionConfig.getTableDimensions()
    return scale, width, depth
  end)
  
  if not success then
    local errMsg = 'Error getting card scale: ' .. tostring(scale)
    log(errMsg)
    print(errMsg)
    return nil
  end
  
  local msg = '=== CARD SCALING INFORMATION ===\n' ..
              'Table dimensions: ' .. tableWidth .. ' x ' .. tableDepth .. '\n' ..
              'Recommended card scale: ' .. scale .. '\n\n' ..
              'Instructions:\n' ..
              '1. Select all bean deck objects in TTS\n' ..
              '2. Set their scale to: ' .. scale .. '\n' ..
              '3. Save the game\n' ..
              '4. Cards will now be properly scaled relative to the table\n' ..
              '================================'
  
  log(msg)
  print('Card scale: ' .. scale)
  print('See log (F12) for full instructions')
  
  return scale
end

-- Also make it accessible via Global scope explicitly
_G.getCardScale = getCardScale
