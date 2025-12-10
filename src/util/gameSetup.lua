--- Game Setup Manager
--- Handles initialization of all game objects and player spaces
local Constants = require('src.util.constants')
local GuidList = require('src.util.guidList')
local PositionConfig = require('src.util.positionConfig')

local GameSetup = {}

-- Store original field positions so we can restore them later
local fieldPositions = {}

--- Initializes all player hand zones
--- @param center table The center object to position hands relative to
function GameSetup.initHands(center)
  local centerPos = center.getPosition()
  local centerRot = center.getRotation()
  
  for color, offset in pairs(PositionConfig.Hands.positions) do
    local hand = getObjectFromGUID(GuidList.Players[color].Hand)
    if hand then
      hand.setPosition(centerPos + offset)
      hand.setRotation(centerRot + PositionConfig.Hands.rotations[color])
      hand.setScale(PositionConfig.Hands.scale)
    end
  end
end

--- Initializes the rules book
--- @param center table The center object to position rules relative to
function GameSetup.initRules(center)
  local rules = getObjectFromGUID(GuidList.Rules)
  if not rules then
    return
  end
  
  local centerPos = center.getPosition()
  rules.setPosition(centerPos + PositionConfig.Rules.position)
  rules.setRotation(PositionConfig.Rules.rotation)
  rules.locked = true
  rules.interactable = true
end

--- Initializes all bean decks
--- @param center table The center object to position decks relative to
function GameSetup.initBeanDecks(center)
  local centerPos = center.getPosition()
  local centerRot = center.getRotation()
  local xPos = PositionConfig.BeanDecks.startX
  
  for name, beanData in pairs(GuidList.BeanDecks) do
    local deck = getObjectFromGUID(beanData.Guid)
    if deck then
      deck.setPosition(centerPos + Vector(xPos, PositionConfig.BeanDecks.yOffset, PositionConfig.BeanDecks.zOffset))
      deck.setRotation(centerRot + PositionConfig.BeanDecks.rotation)
      deck.setScale({3.80000007152557, 1, 3.80000007152557})
      deck.interactable = true
      deck.locked = true
      xPos = xPos + PositionConfig.BeanDecks.spacing
    end
  end
end

--- Initializes a single field
--- @param field table The field object
--- @param handPos Vector The hand position
--- @param handRot Vector The hand rotation
--- @param fieldOffset Vector The offset from hand position
--- @param debug boolean Whether in debug mode
local function initField(field, handPos, handRot, fieldOffset, debug)
  if not field then
    return
  end
  
  field.interactable = debug
  field.locked = true
  
  -- Calculate the correct position
  local correctPos = handPos + fieldOffset
  
  -- Set field scale (hardcoded to match card size with margin)
  field.setScale(PositionConfig.Fields.scale)
  
  -- Store the correct position and scale for later restoration
  local fieldGuid = field.getGUID()
  fieldPositions[fieldGuid] = {
    position = correctPos,
    rotation = handRot,
    scale = PositionConfig.Fields.scale
  }
  
  -- Move field far away to hide it (way below the table)
  field.setPosition(correctPos + Vector(0, -1000, 0))
  field.setRotation(handRot)
end

--- Initializes all player spaces (fields)
function GameSetup.initPlayerSpace()
  for color, playerObj in pairs(GuidList.Players) do
    local hand = getObjectFromGUID(playerObj.Hand)
    if hand then
      local handPos = hand.getPosition()
      local handRot = hand.getRotation()
      local layout = PositionConfig.getFieldLayout(color)
      
      -- Initialize all three fields
      local leftField = getObjectFromGUID(playerObj.LeftField)
      initField(leftField, handPos, handRot, layout.left, Constants.DEBUG)
      
      local middleField = getObjectFromGUID(playerObj.MiddleField)
      initField(middleField, handPos, handRot, layout.middle, Constants.DEBUG)
      
      local rightField = getObjectFromGUID(playerObj.RightField)
      initField(rightField, handPos, handRot, layout.right, Constants.DEBUG)
    end
  end
end

--- Sets up the initial notes for the game
function GameSetup.setNotes()
  Notes.setNotes(
    'Welcome to Bohnanza!\n\n' ..
    'This is setup for basic scripting and supports 3-7 players. (Duo coming soon)\n' ..
    'Every player has 3 fields and a score bag that is only visible to them.\n\n' ..
    'Once all players are seated, use the button to start the game.\n\n' ..
    'Have fun!'
  )
end

--- Initializes all score bags (position, color, and hide completely)
--- @param center table The center object to position bags relative to
function GameSetup.initScoreBags(center)
  local centerRot = center.getRotation()
  
  -- Player color to TTS color mapping
  local colorMap = {
    White = Color.White,
    Orange = Color.Orange,
    Green = Color.Green,
    Yellow = Color.Yellow,
    Red = Color.Red,
    Pink = Color.Pink,
    Purple = Color.fromString('Purple')  -- Purple needs special handling
  }
  
  for color, playerObj in pairs(GuidList.Players) do
    local scoreBag = getObjectFromGUID(playerObj.Score)
    local middleField = getObjectFromGUID(playerObj.MiddleField)
    
    if scoreBag and middleField then
      -- Get the middle field's position
      local fieldPos = middleField.getPosition()
      local bagPos
      
      -- Calculate bag position based on player color
      if color == 'White' or color == 'Orange' or color == 'Green' then
        -- Bottom players: x matches field, z = -40 (absolute)
        bagPos = Vector(fieldPos.x, 1.30, -40)
      elseif color == 'Yellow' or color == 'Red' then
        -- Right side players: x = 60 (absolute), z matches field
        bagPos = Vector(60, 1.30, fieldPos.z)
      elseif color == 'Pink' or color == 'Purple' then
        -- Left side players: x = -60 (absolute), z matches field
        bagPos = Vector(-60, 1.30, fieldPos.z)
      end
      
      if bagPos then
        -- Position the score bag
        scoreBag.setPosition(bagPos)
        scoreBag.setRotation(centerRot)
        scoreBag.setScale(PositionConfig.ScoreBags.scale)
        
        -- Color the bag to match player color
        local bagColor = colorMap[color]
        if bagColor then
          scoreBag.setColorTint(bagColor)
        end
        
        -- Hide the bag completely (invisible to all players)
        scoreBag.setInvisibleTo(Player.getColors())
        
        -- Lock the bag in place
        scoreBag.locked = true
        scoreBag.interactable = true
      end
    end
  end
end

--- Shows score bags only to their respective owners (called during game start)
--- @param Functions table The Functions utility module
function GameSetup.showScoreBags(Functions)
  local seatedPlayers = getSeatedPlayers()
  local seatedColorSet = {}
  
  -- Create a set of seated player colors for quick lookup
  for _, color in ipairs(seatedPlayers) do
    seatedColorSet[color] = true
  end
  
  -- Handle all player colors
  for color, playerObj in pairs(GuidList.Players) do
    local scoreBag = getObjectFromGUID(playerObj.Score)
    if scoreBag then
      if seatedColorSet[color] then
        -- Seated player: Make visible only to the owning player
        scoreBag.setInvisibleTo(Functions.allButCurrentPlayer(color))
      else
        -- Empty seat: Hide completely
        scoreBag.setInvisibleTo(Player.getColors())
      end
    end
  end
end

--- Calculates the correct position for a field based on its hand position
--- @param color string Player color
--- @param fieldType string Field type ('LeftField', 'MiddleField', or 'RightField')
--- @return table|nil Position data {position, rotation, scale} or nil if hand not found
local function calculateFieldPosition(color, fieldType)
  local playerObj = GuidList.Players[color]
  if not playerObj then 
    log('calculateFieldPosition: No player object for color ' .. color)
    return nil 
  end
  
  local hand = getObjectFromGUID(playerObj.Hand)
  if not hand then 
    log('calculateFieldPosition: No hand found for color ' .. color)
    return nil 
  end
  
  local handPos = hand.getPosition()
  local handRot = hand.getRotation()
  local layout = PositionConfig.getFieldLayout(color)
  
  local fieldOffset
  if fieldType == 'LeftField' then
    fieldOffset = layout.left
  elseif fieldType == 'MiddleField' then
    fieldOffset = layout.middle
  elseif fieldType == 'RightField' then
    fieldOffset = layout.right
  else
    return nil
  end
  
  local pos = {
    position = handPos + fieldOffset,
    rotation = handRot,
    scale = PositionConfig.Fields.scale
  }
  log('calculateFieldPosition: ' .. color .. ' ' .. fieldType .. ' -> ' .. tostring(pos.position))
  return pos
end

--- Shows fields for seated players (hides fields for non-seated players)
function GameSetup.showFieldsForSeatedPlayers()
  local seatedPlayers = getSeatedPlayers()
  local seatedColorSet = {}
  
  -- Create a set of seated player colors for quick lookup
  for _, color in ipairs(seatedPlayers) do
    seatedColorSet[color] = true
  end
  
  log('showFieldsForSeatedPlayers called - Seated players: ' .. table.concat(seatedPlayers, ', '))
  
  -- For each player color, show or hide their fields
  for color, playerObj in pairs(GuidList.Players) do
    local isSeated = seatedColorSet[color] == true
    
    -- Get all three fields for this player
    local leftField = getObjectFromGUID(playerObj.LeftField)
    local middleField = getObjectFromGUID(playerObj.MiddleField)
    local rightField = getObjectFromGUID(playerObj.RightField)
    
    local fields = {
      {field = leftField, name = 'Left', type = 'LeftField'},
      {field = middleField, name = 'Middle', type = 'MiddleField'},
      {field = rightField, name = 'Right', type = 'RightField'}
    }
    
    for _, fieldData in ipairs(fields) do
      local field = fieldData.field
      if field then
        local fieldGuid = field.getGUID()
        -- Try to use stored position first, otherwise calculate it
        local storedPos = fieldPositions[fieldGuid]
        if not storedPos then
          log('  No stored position for ' .. color .. ' ' .. fieldData.name .. ', calculating...')
          storedPos = calculateFieldPosition(color, fieldData.type)
        else
          log('  Using stored position for ' .. color .. ' ' .. fieldData.name)
        end
        
        if isSeated then
          -- Move field back to its correct position and restore scale
          if storedPos then
            local oldPos = field.getPosition()
            log('  ' .. color .. ' ' .. fieldData.name .. ': Moving from ' .. tostring(oldPos) .. ' to ' .. tostring(storedPos.position))
            field.setPositionSmooth(storedPos.position, false, false)
            field.setRotation(storedPos.rotation)
            if storedPos.scale then
              field.setScale(storedPos.scale)
            end
            field.interactable = false
            field.locked = true
            -- Initialize the field UI properly - do this after a short delay to ensure field has moved
            Wait.time(function()
              if field then
                -- For right fields with 4+ players, keep them locked (don't unlock)
                -- For other fields, unlock them
                local playerCount = #getSeatedPlayers()
                local shouldUnlock = fieldData.name ~= 'Right' or playerCount == 3
                
                if shouldUnlock then
                  -- Call the field's unlockField function to properly set up UI
                  pcall(function()
                    field.call('unlockField')
                  end)
                else
                  -- Right field for 4+ players: keep locked, set up locked field UI
                  if field.UI then
                    field.UI.show('field')
                    field.UI.setAttribute('field', 'color', Constants.LockedFieldColor)
                    field.UI.setAttribute('unlockFieldBtn', 'active', 'true')
                  end
                end
                log('  ' .. color .. ' ' .. fieldData.name .. ': Initialized field UI (unlocked=' .. tostring(shouldUnlock) .. ')')
              end
            end, 0.2)
          else
            log('  ERROR: ' .. color .. ' ' .. fieldData.name .. ': No position data available!')
          end
        else
          -- Keep field far away (hidden)
          if storedPos then
            log('  ' .. color .. ' ' .. fieldData.name .. ': Hiding (empty seat)')
            field.setPosition(storedPos.position + Vector(0, -1000, 0))
            -- Keep non-seated fields non-interactable
            field.interactable = false
          end
        end
      else
        log('  ERROR: Field not found for ' .. color .. ' ' .. fieldData.name)
      end
    end
  end
end

--- Explicitly hides all fields by moving them far away (called after setup to ensure they're hidden)
function GameSetup.hideAllFields()
  for color, playerObj in pairs(GuidList.Players) do
    local leftField = getObjectFromGUID(playerObj.LeftField)
    local middleField = getObjectFromGUID(playerObj.MiddleField)
    local rightField = getObjectFromGUID(playerObj.RightField)
    
    local fields = {
      {field = leftField, name = 'Left'},
      {field = middleField, name = 'Middle'},
      {field = rightField, name = 'Right'}
    }
    
    for _, fieldData in ipairs(fields) do
      local field = fieldData.field
      if field then
        local fieldGuid = field.getGUID()
        local storedPos = fieldPositions[fieldGuid]
        if storedPos then
          -- Move field far away
          field.setPosition(storedPos.position + Vector(0, -1000, 0))
        end
      end
    end
  end
end

--- Runs all setup procedures
--- @param center table The center object
--- @param Functions table The Functions utility module
function GameSetup.setupAll(center, Functions)
  GameSetup.initHands(center)
  GameSetup.initRules(center)
  GameSetup.initBeanDecks(center)
  GameSetup.initPlayerSpace()
  GameSetup.initScoreBags(center)
  GameSetup.setNotes()
  
  -- Fields are already moved away during initField, but ensure they stay hidden
  -- Wait a moment to ensure all objects are fully initialized
  Wait.time(function()
    GameSetup.hideAllFields()
  end, 0.5)
end

return GameSetup


