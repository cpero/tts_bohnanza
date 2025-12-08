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

-- Timer reference for periodic button updates
local buttonUpdateTimer = nil

-- Track which player colors have been sat in (for hotseat mode)
local satInColors = {}

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
  
  log('validateSeatedPlayers: Found ' .. #seatedPlayers .. ' seated players')
  for i, color in ipairs(seatedPlayers) do
    log('  Player ' .. i .. ': ' .. tostring(color))
    -- Track this color as having been sat in (for hotseat mode)
    if color and GuidList.Players[color] then
      satInColors[color] = true
    end
  end
  
  -- Count unique colors that have been sat in
  local uniqueColorCount = 0
  for color, _ in pairs(satInColors) do
    if GuidList.Players[color] then
      uniqueColorCount = uniqueColorCount + 1
    end
  end
  
  log('  Unique colors sat in: ' .. uniqueColorCount)
  
  -- In hotseat mode, getSeatedPlayers() might only return the current player
  -- So we check how many unique colors have been sat in
  if #seatedPlayers == 1 then
    -- Hotseat mode: need at least 3 different colors to have been sat in
    if uniqueColorCount >= 3 then
      log('  Hotseat mode: 3+ colors sat in, validation passed')
      return true
    else
      log('  Hotseat mode: Only ' .. uniqueColorCount .. ' colors sat in, need 3')
      return false
    end
  end
  
  -- Multiplayer mode: need at least 3 players currently seated
  if #seatedPlayers < 3 then
    log('  Validation failed: Need at least 3 players, found ' .. #seatedPlayers)
    return false
  end
  
  -- Check that all seated players have valid colors
  for _, playerColor in ipairs(seatedPlayers) do
    if not GuidList.Players[playerColor] then
      log('  Validation failed: Invalid player color: ' .. tostring(playerColor))
      return false
    end
  end
  
  log('  Validation passed!')
  return true
end

--- Updates the start game button interactability based on player count and valid colors
local function updateStartGameButton()
  local isValid = validateSeatedPlayers()
  
  log('updateStartGameButton: isValid=' .. tostring(isValid))
  
  -- Keep button always interactable so onClick always fires
  -- We'll handle validation inside onClick and show error messages
  -- But we can change the visual appearance
  if isValid then
    self.UI.setAttribute('startGameBtn', 'interactable', 'true')
    self.UI.setAttribute('startGameBtn', 'color', '#FFFFFF')
    log('  Button enabled')
  else
    self.UI.setAttribute('startGameBtn', 'interactable', 'true')
    self.UI.setAttribute('startGameBtn', 'color', '#888888')
    log('  Button disabled (visual only)')
  end
end

--- Updates both variant and start game button states
local function updateButtonStates()
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
    updateVariantUI()
  end
  
  -- Update start game button based on player count
  updateStartGameButton()
end

--- Starts periodic button state updates (stops when game starts)
local function startPeriodicButtonUpdates()
  -- Stop any existing timer
  if buttonUpdateTimer then
    Wait.stop(buttonUpdateTimer)
    buttonUpdateTimer = nil
  end
  
  -- Only start periodic updates if game hasn't started
  if not state.started then
    buttonUpdateTimer = Wait.time(function()
      if not state.started then
        updateButtonStates()
        -- Continue checking every 0.5 seconds until game starts
        startPeriodicButtonUpdates()
      end
    end, 0.5)
  end
end

--- Stops periodic button state updates
local function stopPeriodicButtonUpdates()
  if buttonUpdateTimer then
    Wait.stop(buttonUpdateTimer)
    buttonUpdateTimer = nil
  end
end

--- Called when the object is loaded
--- @param script_state string JSON-encoded state from previous session
function onLoad(script_state)
  if script_state ~= '' then
    state = JSON.decode(script_state)
  end
  
  -- Reset sat-in colors tracking
  satInColors = {}
  
  -- Track initial seated players
  local seatedPlayers = getSeatedPlayers()
  for _, color in ipairs(seatedPlayers) do
    if color and GuidList.Players[color] then
      satInColors[color] = true
    end
  end
  
  -- Update immediately (for already-seated players)
  updateButtonStates()
  
  -- Also update after a short delay (for players connecting)
  Wait.time(function()
    updateButtonStates()
  end, 1)
  
  -- Start periodic updates to catch any edge cases
  startPeriodicButtonUpdates()
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
    local msg = 'The game has already started!'
    log('Broadcasting: ' .. msg)
    print(msg)
    pcall(function()
      broadcastToAll(msg, { r = 1, g = 0, b = 0 })
    end)
    return
  end
  
  -- Validate players
  if not validateSeatedPlayers() then
    local seatedPlayers = getSeatedPlayers()
    local playerCount = #seatedPlayers
    
    -- Count unique colors that have been sat in
    local uniqueColorCount = 0
    for color, _ in pairs(satInColors) do
      if GuidList.Players[color] then
        uniqueColorCount = uniqueColorCount + 1
      end
    end
    
    -- Check for invalid colors first
    local invalidColors = {}
    for _, playerColor in ipairs(seatedPlayers) do
      if not GuidList.Players[playerColor] then
        table.insert(invalidColors, playerColor)
      end
    end
    
    local msg = ''
    if #invalidColors > 0 then
      msg = 'Cannot start game: Players must be seated in valid colors! ' ..
            'Invalid colors: ' .. table.concat(invalidColors, ', ')
    elseif playerCount == 1 then
      -- Hotseat mode: need to sit in at least 3 different colors
      if uniqueColorCount < 3 then
        msg = 'You need to sit in at least 3 different player colors to start the game! ' ..
              'Currently sat in: ' .. uniqueColorCount .. ' color(s). ' ..
              'Switch to different player colors and try again.'
      else
        msg = 'Cannot start game: Please ensure all player colors are valid.'
      end
    else
      -- Multiplayer mode: need at least 3 players
      if playerCount < 3 then
        msg = 'You need at least 3 players to start the game! ' ..
              'Currently have: ' .. playerCount .. ' player(s).'
      else
        msg = 'Cannot start game: Please ensure all players are seated in valid colors.'
      end
    end
    
    -- Broadcast the message - use print() which definitely works in TTS
    log('Broadcasting error message: ' .. msg)
    print(msg)
    
    -- Also try broadcastToAll (may not work in hotseat)
    local success, err = pcall(function()
      broadcastToAll(msg, { r = 1, g = 0, b = 0 })
    end)
    if not success then
      log('broadcastToAll failed: ' .. tostring(err))
    end
    
    return
  end
  
  -- Get valid player count
  local playerCount = #getSeatedPlayers()
  
  -- Stop periodic button updates
  stopPeriodicButtonUpdates()
  
  -- Show fields for seated players first (they must be visible before unlocking)
  GameSetup.showFieldsForSeatedPlayers()
  
  -- If 3 players, unlock all fields (all players start with all 3 fields unlocked)
  if playerCount == 3 then
    log('3-player game: Unlocking all fields for all players')
    -- Wait a moment for fields to become visible before unlocking
    Wait.time(function()
      unlockAllFieldsForPlayers()
      -- Wait a moment for fields to unlock before proceeding
      Wait.time(function()
        startGameProcess()
      end, 0.5)
    end, 0.2)
  else
    -- 4+ players: Right fields remain locked (default behavior)
    startGameProcess()
  end
end

--- Internal function to start the game after field setup
function startGameProcess()
  -- Note: Fields are already shown by this point
  
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

--- Called when a player connects to the game
function onPlayerConnect(player)
  if state.started then
    return
  end
  
  -- Wait a moment for player to be seated, then update button
  Wait.time(function()
    updateButtonStates()
  end, 0.5)
end

--- Called when a player disconnects from the game
function onPlayerDisconnect(player)
  if state.started then
    return
  end
  
  -- Update button states immediately
  updateButtonStates()
end

--- Called when a player changes their seat color
function onPlayerChangeColor()
  if state.started then
    return
  end
  
  -- Track the new color
  local seatedPlayers = getSeatedPlayers()
  for _, color in ipairs(seatedPlayers) do
    if color and GuidList.Players[color] then
      satInColors[color] = true
    end
  end
  
  log('onPlayerChangeColor: Tracked colors:')
  for color, _ in pairs(satInColors) do
    log('  - ' .. tostring(color))
  end
  
  -- Update button states
  updateButtonStates()
end

--- Unlocks all fields for all seated players (for 3-player games)
function unlockAllFieldsForPlayers()
  local seatedPlayers = getSeatedPlayers()
  log('Unlocking all fields for ' .. #seatedPlayers .. ' seated players')
  
  for _, playerColor in ipairs(seatedPlayers) do
    local playerData = GuidList.Players[playerColor]
    if playerData then
      -- Unlock the Right field (third field) for this player
      local rightField = getObjectFromGUID(playerData.RightField)
      if rightField then
        log('  Unlocking Right field for ' .. playerColor)
        local success, err = pcall(function()
          rightField.call('unlockField')
        end)
        if not success then
          log('ERROR: Failed to unlock field for ' .. playerColor .. ': ' .. tostring(err))
        end
      else
        log('WARNING: Right field not found for ' .. playerColor)
      end
    else
      log('WARNING: Player data not found for ' .. playerColor)
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

