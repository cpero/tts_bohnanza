--- Global Script
--- Main entry point for the mod, handles initial setup

local GuidList = require('src.util.guidList')
local Constants = require('src.util.constants')

local state = {
  stage = 1,
  seatedPlayers = {},
}

--- Called when the mod is loaded
--- @param script_state string JSON-encoded state from previous session
function onLoad(script_state)
  if script_state ~= '' then
    state = JSON.decode(script_state)
    log('Found state. Loading...')
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
        log('Game setup completed')
      else
        log('ERROR: Center object not found!')
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
