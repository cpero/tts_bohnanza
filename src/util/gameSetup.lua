--- Game Setup Manager
--- Handles initialization of all game objects and player spaces
local Constants = require('src.util.constants')
local GuidList = require('src.util.guidList')
local PositionConfig = require('src.util.positionConfig')

local GameSetup = {}

--- Initializes all player hand zones
--- @param center table The center object to position hands relative to
function GameSetup.initHands(center)
  log('Initializing player hands')
  
  local centerPos = center.getPosition()
  local centerRot = center.getRotation()
  
  for color, offset in pairs(PositionConfig.Hands.positions) do
    local hand = getObjectFromGUID(GuidList.Players[color].Hand)
    if hand then
      hand.setPosition(centerPos + offset)
      hand.setRotation(centerRot + PositionConfig.Hands.rotations[color])
      hand.setScale(PositionConfig.Hands.scale)
    else
      log('WARNING: Hand not found for color: ' .. color)
    end
  end
end

--- Initializes the rules book
--- @param center table The center object to position rules relative to
function GameSetup.initRules(center)
  log('Initializing rules')
  
  local rules = getObjectFromGUID(GuidList.Rules)
  if not rules then
    log('ERROR: Rules object not found')
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
  log('Initializing bean decks')
  
  local centerPos = center.getPosition()
  local centerRot = center.getRotation()
  local xPos = PositionConfig.BeanDecks.startX
  
  for name, beanData in pairs(GuidList.BeanDecks) do
    local deck = getObjectFromGUID(beanData.Guid)
    if deck then
      deck.setPosition(centerPos + Vector(xPos, PositionConfig.BeanDecks.yOffset, PositionConfig.BeanDecks.zOffset))
      deck.setRotation(centerRot + PositionConfig.BeanDecks.rotation)
      deck.interactable = Constants.DEBUG
      deck.locked = not Constants.DEBUG
      xPos = xPos + PositionConfig.BeanDecks.spacing
    else
      log('WARNING: Bean deck not found: ' .. name)
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
  field.setPosition(handPos + fieldOffset)
  field.setRotation(handRot)
end

--- Initializes all player spaces (fields)
function GameSetup.initPlayerSpace()
  log('Initializing player space')
  
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
    else
      log('WARNING: Hand not found for ' .. color)
    end
  end
end

--- Sets up the initial notes for the game
function GameSetup.setNotes()
  Notes.setNotes(
    'Welcome to Bohnanza!\n\n' ..
    'This is setup for basic scripting and supports 2-7 players.\n' ..
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

--- Runs all setup procedures
--- @param center table The center object
--- @param Functions table The Functions utility module
function GameSetup.setupAll(center, Functions)
  log('Setting up game...')
  GameSetup.initHands(center)
  GameSetup.initRules(center)
  GameSetup.initBeanDecks(center)
  GameSetup.initPlayerSpace()
  GameSetup.setNotes()
  GameSetup.hideScoreBags(Functions)
end

return GameSetup

