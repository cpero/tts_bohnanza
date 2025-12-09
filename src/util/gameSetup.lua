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
      deck.interactable = Constants.DEBUG
      deck.locked = not Constants.DEBUG
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

--- Hides score bags from other players
--- @param Functions table The Functions utility module
function GameSetup.hideScoreBags(Functions)
  for _, color in ipairs(getSeatedPlayers()) do
    local playerObj = GuidList.Players[color]
    if playerObj then
      local scoreBag = getObjectFromGUID(playerObj.Score)
      if scoreBag then
        scoreBag.setInvisibleTo(Functions.allButCurrentPlayer(color))
      end
    end
  end
end

--- Shows fields for seated players (hides fields for non-seated players)
function GameSetup.showFieldsForSeatedPlayers()
  local seatedPlayers = getSeatedPlayers()
  local seatedColorSet = {}
  
  -- Create a set of seated player colors for quick lookup
  for _, color in ipairs(seatedPlayers) do
    seatedColorSet[color] = true
  end
  
  -- For each player color, show or hide their fields
  for color, playerObj in pairs(GuidList.Players) do
    local isSeated = seatedColorSet[color] == true
    
    -- Get all three fields for this player
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
        
        if isSeated then
          -- Move field back to its correct position and restore scale
          if storedPos then
            field.setPosition(storedPos.position)
            field.setRotation(storedPos.rotation)
            if storedPos.scale then
              field.setScale(storedPos.scale)
            end
          end
        else
          -- Keep field far away (hidden)
          if storedPos then
            field.setPosition(storedPos.position + Vector(0, -1000, 0))
          end
        end
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
  GameSetup.setNotes()
  GameSetup.hideScoreBags(Functions)
  
  -- Fields are already moved away during initField, but ensure they stay hidden
  -- Wait a moment to ensure all objects are fully initialized
  Wait.time(function()
    GameSetup.hideAllFields()
  end, 0.5)
end

return GameSetup

