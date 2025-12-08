--- Center Control Object
--- Main game controller attached to the center object
--- Handles game start, UI interactions, and variant mode

local Constants = require('src.util.constants')
local GuidList = require('src.util.guidList')
local Functions = require('src.util.functions')
local GameSetup = require('src.util.gameSetup')
local GameStart = require('src.util.gameStart')
local PositionConfig = require('src.util.positionConfig')

-- Game state
local state = {
  started = false,
  variant = true
}

--- Updates the variant mode button UI
local function updateVariantUI()
  if state.variant then
    self.UI.setAttribute('toggleVariantBtn', 'text', 'Variant Mode: Enabled')
    self.UI.setAttribute('toggleVariantBtn', 'color', 'green')
  else
    self.UI.setAttribute('toggleVariantBtn', 'text', 'Variant Mode: Disabled')
    self.UI.setAttribute('toggleVariantBtn', 'color', 'red')
  end
end

--- Validates that all seated players have valid colors
--- @return boolean True if all players have valid colors
local function validateSeatedPlayers()
  local seatedPlayers = getSeatedPlayers()
  
  -- Need at least 3 players
  if #seatedPlayers < 3 then
    return false
  end
  
  -- Check that all seated players have valid colors
  for _, playerColor in ipairs(seatedPlayers) do
    if not GuidList.Players[playerColor] then
      return false
    end
  end
  
  return true
end

--- Updates the start game button interactability based on player count and valid colors
local function updateStartGameButton()
  local isValid = validateSeatedPlayers()
  
  if isValid then
    self.UI.setAttribute('startGameBtn', 'interactable', 'true')
  else
    self.UI.setAttribute('startGameBtn', 'interactable', 'false')
  end
end

--- Called when the object is loaded
--- @param script_state string JSON-encoded state from previous session
function onLoad(script_state)
  if script_state ~= '' then
    state = JSON.decode(script_state)
  end
  
  -- Update UI based on current player count
  updateStartGameButton()
end

--- Called when the game is saved
--- @return string JSON-encoded state (empty in debug mode)
function onSave()
  GameSetup.hideScoreBags(Functions)
  
  if Constants.DEBUG then
    return ''
  else
    return JSON.encode(state)
  end
end

--- Sets up the game board (can be called externally)
function setupGame()
  -- Allow re-setup in DEBUG mode
  if state.started and not Constants.DEBUG then
    log('Game already started')
    return
  end
  
  -- Get the center object (self in this context)
  local center = self
  GameSetup.setupAll(center, Functions)
end

--- Handles the "Start Game" button click
function onClickStartGame()
  log('Starting game...')
  
  if state.started then
    log('Game already started')
    return
  end
  
  -- Validate players
  if not validateSeatedPlayers() then
    local seatedPlayers = getSeatedPlayers()
    local playerCount = #seatedPlayers
    
    if playerCount < 3 then
      broadcastToAll('You need at least 3 players to start the game!', { r = 1, g = 0, b = 0 })
    else
      -- Find invalid colors
      local invalidColors = {}
      for _, playerColor in ipairs(seatedPlayers) do
        if not GuidList.Players[playerColor] then
          table.insert(invalidColors, playerColor)
        end
      end
      
      broadcastToAll(
        'Cannot start game: Players must be seated in valid colors! ' ..
        'Invalid colors: ' .. table.concat(invalidColors, ', '),
        { r = 1, g = 0, b = 0 }
      )
    end
    return
  end
  
  -- Get valid player count
  local playerCount = #getSeatedPlayers()
  
  -- If 3 players, unlock all fields (all players start with all 3 fields unlocked)
  if playerCount == 3 then
    log('3-player game: Unlocking all fields for all players')
    unlockAllFieldsForPlayers()
    -- Wait a moment for fields to unlock before proceeding
    Wait.time(function()
      startGameProcess()
    end, 0.5)
  else
    -- 4+ players: Right fields remain locked (default behavior)
    startGameProcess()
  end
end

--- Internal function to start the game after field setup
function startGameProcess()
  -- Update UI
  self.UI.setAttribute('tableSetup', 'active', 'false')
  self.UI.setAttribute('gameLayout', 'active', 'true')
  self.UI.setAttribute('draw', 'color', Constants.DrawDeckColor)
  self.UI.setAttribute('discard', 'color', Constants.DiscardDeckColor)
  
  -- Set up snap points for draw and discard piles
  self.setSnapPoints(PositionConfig.CenterSnapPoints)
  
  -- Clear notes
  Notes.setNotes('')
  
  -- Combine, shuffle, and deal cards
  GameStart.startGame(self, state.variant, 5)
  
  state.started = true
end

--- Handles the "Toggle Variant" button click
function onClickToggleVariant()
  if state.started then
    log('Game already started')
    return
  end
  
  state.variant = not state.variant
  log('Variant mode: ' .. tostring(state.variant))
  
  updateVariantUI()
end

--- Called when a player changes their seat color
function onPlayerChangeColor()
  if state.started then
    return
  end
  
  local playerCount = #getSeatedPlayers()
  
  -- Force variant mode for 6+ players
  if playerCount >= 6 then
    self.UI.setAttribute('toggleVariantBtn', 'text', 'Variant Mode: Enabled')
    self.UI.setAttribute('toggleVariantBtn', 'color', 'green')
    self.UI.setAttribute('toggleVariantBtn', 'interactable', 'false')
    state.variant = true
  else
    self.UI.setAttribute('toggleVariantBtn', 'interactable', 'true')
  end
  
  -- Update start game button based on player count
  updateStartGameButton()
end

--- Unlocks all fields for all seated players (for 3-player games)
function unlockAllFieldsForPlayers()
  local seatedPlayers = getSeatedPlayers()
  
  for _, playerColor in ipairs(seatedPlayers) do
    local playerData = GuidList.Players[playerColor]
    if playerData then
      -- Unlock the Right field (third field) for this player
      local rightField = getObjectFromGUID(playerData.RightField)
      if rightField then
        rightField.call('unlockField')
      end
    end
  end
end

--- Gets the current game state (for debugging)
--- @return table The current game state
function getGameState()
  return state
end

--- Checks if the game has started
--- @return boolean True if the game has started
function isGameStarted()
  return state.started
end

--- Checks if variant mode is enabled
--- @return boolean True if variant mode is enabled
function isVariantMode()
  return state.variant
end

