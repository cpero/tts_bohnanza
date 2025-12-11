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
  variant = true,
  shuffleCount = 0  -- Track number of times deck has been shuffled
}

-- Zone references for draw and discard
local drawZone = nil
local discardZone = nil

-- Deck references
local drawDeck = nil
local discardDeck = nil

-- Timer reference for periodic button updates
local buttonUpdateTimer = nil

-- Track which player colors have been sat in (for hotseat mode)
local satInColors = {}

--- Updates the variant mode button UI
local function updateVariantUI()
  local playerCount = #getSeatedPlayers()
  
  -- Force variant mode for 6+ players and disable button
  if playerCount >= 6 then
    self.UI.setAttribute('toggleVariantBtn', 'text', 'Variant Mode: Enabled (Required)')
    self.UI.setAttribute('toggleVariantBtn', 'color', 'green')
    self.UI.setAttribute('toggleVariantBtn', 'interactable', 'false')
    state.variant = true
  else
    -- Enable button and show current state
    self.UI.setAttribute('toggleVariantBtn', 'interactable', 'true')
    if state.variant then
      self.UI.setAttribute('toggleVariantBtn', 'text', 'Variant Mode: Enabled')
      self.UI.setAttribute('toggleVariantBtn', 'color', 'green')
    else
      self.UI.setAttribute('toggleVariantBtn', 'text', 'Variant Mode: Disabled')
      self.UI.setAttribute('toggleVariantBtn', 'color', 'red')
    end
  end
end

--- Validates that all seated players have valid colors
--- @return boolean True if all players have valid colors
local function validateSeatedPlayers()
  local seatedPlayers = getSeatedPlayers()
  
  -- Track this color as having been sat in (for hotseat mode)
  for _, color in ipairs(seatedPlayers) do
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
  
  -- In hotseat mode, getSeatedPlayers() might only return the current player
  -- So we check how many unique colors have been sat in
  if #seatedPlayers == 1 then
    -- Hotseat mode: need at least 3 different colors to have been sat in
    if uniqueColorCount < 3 then
      return false
    end
    return true
  end
  
  -- Multiplayer mode: need at least 3 players currently seated
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
  
  -- Keep button always interactable so onClick always fires
  -- We'll handle validation inside onClick and show error messages
  -- But we can change the visual appearance
  if isValid then
    self.UI.setAttribute('startGameBtn', 'interactable', 'true')
    self.UI.setAttribute('startGameBtn', 'color', '#FFFFFF')
  else
    self.UI.setAttribute('startGameBtn', 'interactable', 'true')
    self.UI.setAttribute('startGameBtn', 'color', '#888888')
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

--- Called when an object enters a zone
--- @param zone table The zone object
--- @param object table The object that entered
function onObjectEnterZone(zone, object)
  if not state.started then
    return
  end
  
  if zone == drawZone then
    if object.type == 'Deck' then
      drawDeck = object
      updateShuffleButtonVisibility()
    end
  elseif zone == discardZone then
    if object.type == 'Deck' then
      discardDeck = object
      updateShuffleButtonVisibility()
    end
  end
end

--- Called when an object leaves a zone
--- @param zone table The zone object
--- @param object table The object that left
function onObjectLeaveZone(zone, object)
  if not state.started then
    return
  end
  
  if zone == drawZone then
    if object == drawDeck then
      drawDeck = nil
      updateShuffleButtonVisibility()
    end
  elseif zone == discardZone then
    if object == discardDeck then
      discardDeck = nil
      updateShuffleButtonVisibility()
    end
  end
end

--- Called when the object is loaded
--- @param script_state string JSON-encoded state from previous session
function onLoad(script_state)
  if script_state ~= '' then
    local loadedState = JSON.decode(script_state)
    if loadedState then
      state = loadedState
      -- Ensure shuffleCount exists (for backwards compatibility)
      if not state.shuffleCount then
        state.shuffleCount = 0
      end
    end
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
  
  -- Fix score bag visibility and field positions on load
  Wait.time(function()
    if state.started then
      -- Game has started: show bags to seated players, hide for empty seats
      GameSetup.showScoreBags(Functions)
      -- Also fix field positions for seated players
      GameSetup.showFieldsForSeatedPlayers()
    else
      -- Game not started: hide all bags completely
      for color, playerObj in pairs(GuidList.Players) do
        local scoreBag = getObjectFromGUID(playerObj.Score)
        if scoreBag then
          scoreBag.setInvisibleTo(Player.getColors())
        end
      end
    end
  end, 0.5)
  
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
  -- Show score bags for seated players if game has started
  if state.started then
    GameSetup.showScoreBags(Functions)
  end
  
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
    return
  end
  
  -- Get the center object (self in this context)
  local center = self
  GameSetup.setupAll(center, Functions)
end

--- Handles the "Start Game" button click
function onClickStartGame()
  if state.started then
    local msg = 'The game has already started!'
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
    print(msg)
    
    -- Also try broadcastToAll (may not work in hotseat)
    pcall(function()
      broadcastToAll(msg, { r = 1, g = 0, b = 0 })
    end)
    
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

--- Creates scripting zones for draw and discard piles
function createDrawDiscardZones()
  local centerPos = self.getPosition()
  local centerRot = self.getRotation()
  
  -- Create draw zone (left position)
  drawZone = spawnObject({
    type = 'ScriptingTrigger',
    position = centerPos + Vector(-6, 0.1, 0),
    rotation = centerRot,
    scale = Vector(2, 0.5, 2),
    callback_function = function(obj)
      if obj then
        obj.setName('Draw Zone')
        obj.setLock(true)
        -- Make zone invisible but functional
        obj.setInvisibleTo(Player.getColors())
      end
    end
  })
  
  -- Create discard zone (right position)
  discardZone = spawnObject({
    type = 'ScriptingTrigger',
    position = centerPos + Vector(6, 0.1, 0),
    rotation = centerRot,
    scale = Vector(2, 0.5, 2),
    callback_function = function(obj)
      if obj then
        obj.setName('Discard Zone')
        obj.setLock(true)
        -- Make zone invisible but functional
        obj.setInvisibleTo(Player.getColors())
      end
    end
  })
  
end

--- Internal function to start the game after field setup
function startGameProcess()
  -- Note: Fields are already shown by this point
  
  -- Update UI
  self.UI.setAttribute('tableSetup', 'active', 'false')
  self.UI.setAttribute('gameLayout', 'active', 'true')
  self.UI.setAttribute('draw', 'color', Constants.DrawDeckColor)
  self.UI.setAttribute('discard', 'color', Constants.DiscardDeckColor)
  
  -- Create scripting zones for draw and discard piles
  createDrawDiscardZones()
  
  -- Clear notes
  Notes.setNotes('')
  
  -- Show score bags to their respective owners
  GameSetup.showScoreBags(Functions)
  
  -- Combine, shuffle, and deal cards
  GameStart.startGame(self, state.variant, 5)
  
  -- Wait for deck to be created and enter draw zone
  Wait.time(function()
    -- Check draw zone for deck or card
    if drawZone then
      local objects = drawZone.getObjects()
      for _, obj in ipairs(objects) do
        if obj.type == 'Deck' or obj.type == 'Card' then
          drawDeck = obj
          break
        end
      end
    end
    updateShuffleButtonVisibility()
  end, 2)
  
  -- Enable turns and select a random first player
  local seatedPlayers = getSeatedPlayers()
  if #seatedPlayers > 0 then
    local randomIndex = math.random(1, #seatedPlayers)
    local firstPlayer = seatedPlayers[randomIndex]
    
    Turns.enable = true
    Turns.type = 1  -- Auto-pass turns (1 = auto pass, 2 = manual, 3 = reverse)
    Turns.turn_color = firstPlayer
    
    broadcastToAll(Player[firstPlayer].steam_name .. ' (' .. firstPlayer .. ') goes first!', {r = 1, g = 1, b = 0})
  end
  
  state.started = true
end

--- Handles the "Toggle Variant" button click
function onClickToggleVariant()
  if state.started then
    return
  end
  
  -- Don't allow toggling if 6+ players (variant is required)
  local playerCount = #getSeatedPlayers()
  if playerCount >= 6 then
    return
  end
  
  state.variant = not state.variant
  updateVariantUI()
end

--- Shuffles the discard pile into the draw pile
function shuffleDiscardIntoDraw()
  if not discardDeck or not drawZone then
    print('Cannot shuffle: Discard pile or draw zone not found!')
    pcall(function()
      broadcastToAll('Cannot shuffle: Discard pile or draw zone not found!', {r = 1, g = 0, b = 0})
    end)
    return
  end
  
  -- Store reference to deck before async operations
  local deckToShuffle = discardDeck
  
  if not deckToShuffle or deckToShuffle.isDestroyed() then
    print('Discard deck is destroyed!')
    return
  end
  
  -- Get discard count (works for both Deck and Card)
  local discardCount = 0
  if deckToShuffle.type == 'Deck' then
    discardCount = deckToShuffle.getQuantity()
  elseif deckToShuffle.type == 'Card' then
    discardCount = 1
  else
    print('Discard pile is not a deck or card!')
    return
  end
  
  if discardCount < 1 then
    print('Discard pile is empty!')
    pcall(function()
      broadcastToAll('Discard pile is empty!', {r = 1, g = 0, b = 0})
    end)
    return
  end
  
  log('Starting shuffle')
  
  -- Move discard deck to draw zone position
  local centerPos = self.getPosition()
  local drawZonePos = drawZone.getPosition()
  
  deckToShuffle.setPositionSmooth(drawZonePos + Vector(0, 2, 0), false, false)
  
  -- Wait for movement to complete, then flip
  Wait.time(function()
    if not deckToShuffle or deckToShuffle.isDestroyed() then
      log('ERROR: Deck destroyed during movement')
      return
    end
    
    
    -- Flip face-down if needed
    if not deckToShuffle.is_face_down then
      deckToShuffle.flip()
    end
    
    -- Wait for flip animation, then shuffle
    Wait.time(function()
      if not deckToShuffle or deckToShuffle.isDestroyed() then
        log('ERROR: Deck destroyed during flip')
        return
      end
            
      -- Shuffle the deck
      deckToShuffle.shuffle()
      
      -- Increment shuffle count
      state.shuffleCount = (state.shuffleCount or 0) + 1
      
      -- Wait for shuffle animation, then broadcast and update
      Wait.time(function()
        if not deckToShuffle or deckToShuffle.isDestroyed() then
          log('ERROR: Deck destroyed after shuffle')
          return
        end
        
        -- Verify deck is in draw zone
        local deckInZone = false
        if drawZone then
          local objects = drawZone.getObjects()
          for _, obj in ipairs(objects) do
            if obj == deckToShuffle or ((obj.type == 'Deck' or obj.type == 'Card') and obj.getGUID() == deckToShuffle.getGUID()) then
              deckInZone = true
              drawDeck = deckToShuffle
              discardDeck = nil
              break
            end
          end
        end
        
        -- Update button visibility
        updateShuffleButtonVisibility()
        
        -- Broadcast shuffle messages
        local msg1 = 'Deck shuffled! (Shuffle #' .. state.shuffleCount .. ')'
        
        print(msg1)
        
        pcall(function()
          broadcastToAll(msg1, {r = 0, g = 1, b = 0})
        end)
        
        -- Check if this is the 3rd shuffle (game ending condition)
        if state.shuffleCount >= 3 then
          Wait.time(function()
            pcall(function()
              broadcastToAll('⚠️ GAME ENDING: Deck has been shuffled 3 times!', {r = 1, g = 0.5, b = 0})
              broadcastToAll('This is the final round - game will end when this deck is depleted!', {r = 1, g = 1, b = 0})
            end)
          end, 0.5)
        end
        
      end, 1.2)
    end, 0.4)
  end, 0.8)
end

--- Handles the "Shuffle" button click
function onClickShuffle()
  if not state.started then
    return
  end
  
  shuffleDiscardIntoDraw()
end

--- Updates the visibility of the shuffle button based on draw deck state
function updateShuffleButtonVisibility()
  if not state.started then
    return
  end
  
  -- Hide button if game has ended (3 shuffles completed)
  if (state.shuffleCount or 0) >= 3 then
    self.UI.setAttribute('shuffleBtn', 'active', 'false')
    return
  end
  
  local shouldShow = false
  
  -- Check if draw deck/card is empty
  local drawEmpty = true
  if drawDeck and not drawDeck.isDestroyed() then
    if drawDeck.type == 'Deck' then
      drawEmpty = (drawDeck.getQuantity() == 0)
    elseif drawDeck.type == 'Card' then
      drawEmpty = false  -- Single card is not empty
    end
  end
  
  if drawEmpty then
    -- Draw deck is empty, check if discard has cards
    local discardHasCards = false
    if discardDeck and not discardDeck.isDestroyed() then
      if discardDeck.type == 'Deck' then
        discardHasCards = (discardDeck.getQuantity() > 0)
      elseif discardDeck.type == 'Card' then
        discardHasCards = true
      end
    end
    
    if discardHasCards then
      shouldShow = true
    end
  end
  
  if shouldShow then
    self.UI.setAttribute('shuffleBtn', 'active', 'true')
  else
    self.UI.setAttribute('shuffleBtn', 'active', 'false')
  end
end

--- Handles the "Flip 2" button click
--- Takes the top 2 cards from the draw deck and places them above the draw/discard UI elements
function onClickFlip2()
  if not state.started then
    return
  end
  
  -- Get draw deck from zone (could be a Deck or a single Card)
  if not drawDeck or drawDeck.isDestroyed() then
    -- Try to find deck or card in draw zone
    if drawZone then
      local objects = drawZone.getObjects()
      for _, obj in ipairs(objects) do
        if obj.type == 'Deck' or obj.type == 'Card' then
          drawDeck = obj
          break
        end
      end
    end
    
    if not drawDeck or drawDeck.isDestroyed() then
      broadcastToAll('No draw deck found in draw zone!', {r = 1, g = 0, b = 0})
      updateShuffleButtonVisibility()
      return
    end
  end
  
  -- Get card count (works for both Deck and Card)
  local deckCount = 0
  if drawDeck.type == 'Deck' then
    deckCount = drawDeck.getQuantity()
  elseif drawDeck.type == 'Card' then
    deckCount = 1
  else
    broadcastToAll('Draw pile is not a deck or card!', {r = 1, g = 0, b = 0})
    updateShuffleButtonVisibility()
    return
  end
  
  -- Handle special cases: 0 cards or 1 card
  if deckCount == 0 then
    -- Deck is empty, need to shuffle discard into draw first
    local discardHasCards = false
    if discardDeck and not discardDeck.isDestroyed() then
      if discardDeck.type == 'Deck' then
        discardHasCards = (discardDeck.getQuantity() > 0)
      elseif discardDeck.type == 'Card' then
        discardHasCards = true
      end
    end
    
    if discardHasCards then
      broadcastToAll('Draw deck empty! Auto-shuffling discard pile...', {r = 1, g = 1, b = 0})
      shuffleDiscardIntoDraw()
      -- Wait for shuffle to complete, then continue with flip
      Wait.time(function()
        -- Try again after shuffle
        Wait.time(function()
          onClickFlip2()
        end, 1.5)
      end, 0.5)
      return
    else
      broadcastToAll('Cannot flip: Both draw and discard piles are empty!', {r = 1, g = 0, b = 0})
      updateShuffleButtonVisibility()
      return
    end
  elseif deckCount == 1 then
    -- Only 1 card: take it first, then shuffle discard and take second card
    local discardHasCards = false
    if discardDeck and not discardDeck.isDestroyed() then
      if discardDeck.type == 'Deck' then
        discardHasCards = (discardDeck.getQuantity() > 0)
      elseif discardDeck.type == 'Card' then
        discardHasCards = true
      end
    end
    
    if not discardHasCards then
      broadcastToAll('Not enough cards! (Need 2, have 1, discard is empty)', {r = 1, g = 0, b = 0})
      updateShuffleButtonVisibility()
      return
    end
    
    -- Take the single card first with smooth animation (same as normal flip)
    local centerPos = self.getPosition()
    local centerRot = self.getRotation()
    
    local card1 = nil
    if drawDeck.type == 'Card' then
      -- It's a single card, move it directly to final position
      card1 = drawDeck
      card1.setPositionSmooth(centerPos + Vector(-6, 1, 15), false, false)
      drawDeck = nil  -- Clear reference since we moved it
      
      -- Flip and rotate the card
      if card1.is_face_down then
        card1.flip()
      end
      card1.setRotation(centerRot + Vector(0, 180, 0))
    else
      -- It's a deck with 1 card, take it first
      local targetPos = centerPos + Vector(-6, 1, 15)
      card1 = drawDeck.takeObject({
        smooth = false  -- Take instantly
      })
      
      -- Immediately move card to target position using setPosition (instant, no smooth)
      if card1 then
        card1.setPosition(targetPos)
        card1.setRotation(centerRot + Vector(0, 180, 0))
        
        -- Flip card face-up if needed
        if card1.is_face_down then
          card1.flip()
        end
      end
    end
    
    if card1 then
      -- Wait a few frames to ensure card is actually moved and out of draw zone
      Wait.frames(function()
        -- Verify card is still valid and actually at target position
        if card1 and not card1.isDestroyed() then
          local currentPos = card1.getPosition()
          local targetPos = centerPos + Vector(-6, 1, 15)
          local distance = Vector.distance(currentPos, targetPos)
          
          -- If card is not at target, force it there
          if distance > 0.5 then
            card1.setPosition(targetPos)
          end
          
          -- Now safe to shuffle - card is positioned away from draw zone
          broadcastToAll('Shuffling discard pile for second card...', {r = 1, g = 1, b = 0})
          shuffleDiscardIntoDraw()
          
          -- Wait for shuffle to complete, then take second card
          Wait.time(function()
            -- Find the new draw deck after shuffle
            local newDrawDeck = nil
            if drawZone then
              local objects = drawZone.getObjects()
              for _, obj in ipairs(objects) do
                if obj.type == 'Deck' or obj.type == 'Card' then
                  newDrawDeck = obj
                  drawDeck = obj
                  break
                end
              end
            end
            
            if newDrawDeck and not newDrawDeck.isDestroyed() then
              -- Take second card
              local card2 = nil
              if newDrawDeck.type == 'Card' then
                card2 = newDrawDeck
                card2.setPositionSmooth(centerPos + Vector(6, 1, 15), false, false)
                drawDeck = nil
              else
                card2 = newDrawDeck.takeObject({
                  position = centerPos + Vector(6, 1, 15),
                  smooth = true
                })
              end
              
              if card2 then
                if card2.is_face_down then
                  card2.flip()
                end
                card2.setRotation(centerRot + Vector(0, 180, 0))
                
                Wait.time(function()
                  updateShuffleButtonVisibility()
                  broadcastToAll('Flipped 2 cards from the draw deck!', {r = 0, g = 1, b = 0})
                end, 0.5)
              else
                updateShuffleButtonVisibility()
                broadcastToAll('Flipped 1 card, but could not draw second card!', {r = 1, g = 1, b = 0})
              end
            else
              updateShuffleButtonVisibility()
              broadcastToAll('Flipped 1 card, but draw deck not found after shuffle!', {r = 1, g = 1, b = 0})
            end
          end, 2.5)  -- Wait for shuffle animation to complete
        else
          broadcastToAll('First card was destroyed before shuffle!', {r = 1, g = 0, b = 0})
        end
      end, 0.3)  -- Wait for card callback (flip/rotate) to complete
    else
      broadcastToAll('Failed to take first card!', {r = 1, g = 0, b = 0})
      updateShuffleButtonVisibility()
    end
    
    return
  end
  
  -- Take the top 2 cards from the deck using takeObject with smooth animations
  local centerPos = self.getPosition()
  local centerRot = self.getRotation()
  
  -- If it's a single Card, we can only take 1 card
  if drawDeck.type == 'Card' then
    -- This shouldn't happen since we check for < 2 cards above, but handle it just in case
    broadcastToAll('Cannot flip 2 cards: Only 1 card in draw pile!', {r = 1, g = 0, b = 0})
    updateShuffleButtonVisibility()
    return
  end
  
  -- Take first card with smooth animation
  local card1 = drawDeck.takeObject({
    position = centerPos + Vector(-6, 1, 15),  -- Final position for first card
    smooth = true,
    callback_function = function(card)
      if card then
        -- Flip card face-up if it's face-down (with smooth animation)
        if card.is_face_down then
          card.flip()
        end
        -- Set rotation
        card.setRotation(centerRot + Vector(0, 180, 0))
      end
    end
  })
  
  if not card1 then
    broadcastToAll('Failed to take first card from the deck!', {r = 1, g = 0, b = 0})
    updateShuffleButtonVisibility()
    return
  end
  
  -- Check if deck is now empty or would be empty after second card
  Wait.time(function()
    -- Check if drawDeck still exists and is a Deck (not a Card)
    if not drawDeck or drawDeck.isDestroyed() or drawDeck.type ~= 'Deck' then
      -- Deck became a card or was destroyed, can't take second card
      updateShuffleButtonVisibility()
      broadcastToAll('Flipped 1 card from the draw deck!', {r = 0, g = 1, b = 0})
      return
    end
    
    local remainingCount = drawDeck.getQuantity()
    
    -- Wait a moment before taking the second card for a staggered effect
    Wait.time(function()
      -- Check again before taking second card
      if not drawDeck or drawDeck.isDestroyed() or drawDeck.type ~= 'Deck' then
        updateShuffleButtonVisibility()
        return
      end
      
      local card2 = drawDeck.takeObject({
        position = centerPos + Vector(6, 1, 15),  -- Final position for second card
        smooth = true,
        callback_function = function(card)
          if card then
            -- Flip card face-up if it's face-down (with smooth animation)
            if card.is_face_down then
              card.flip()
            end
            -- Set rotation
            card.setRotation(centerRot + Vector(0, 180, 0))
          end
        end
      })
      
      if not card2 then
        broadcastToAll('Failed to take second card from the deck!', {r = 1, g = 0, b = 0})
        updateShuffleButtonVisibility()
        return
      end
      
      -- Update shuffle button visibility after cards are taken
      Wait.time(function()
        updateShuffleButtonVisibility()
        broadcastToAll('Flipped 2 cards from the draw deck!', {r = 0, g = 1, b = 0})
      end, 0.5)
    end, 0.3)
  end, 0.1)
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
  
  -- Update button states
  updateButtonStates()
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
        pcall(function()
          rightField.call('unlockField')
        end)
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

--- Gets the recommended card scale for manual scaling
--- Call this from TTS console: getCardScale()
--- @return number The scale factor to apply to cards
function getCardScale()
  local scale = PositionConfig.Cards.getScale()
  local tableWidth, tableDepth = PositionConfig.getTableDimensions()
  
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

--- Gets the shuffle count (for end game requirements)
--- @return number The number of times the deck has been shuffled
function getShuffleCount()
  return state.shuffleCount or 0
end

