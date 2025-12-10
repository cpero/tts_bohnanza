--- Game Start Logic
--- Handles card shuffling, dealing, and game initialization
local Constants = require('src.util.constants')
local GuidList = require('src.util.guidList')
local PositionConfig = require('src.util.positionConfig')

local GameStart = {}

--- Bean types to exclude in non-variant mode
local VARIANT_BEANS = { 'Coffee', 'Cocoa', 'Wax' }

--- Checks if a bean is a variant bean
--- @param beanName string The bean type name
--- @return boolean True if it's a variant bean
local function isVariantBean(beanName)
  for _, variantBean in ipairs(VARIANT_BEANS) do
    if variantBean == beanName then
      return true
    end
  end
  return false
end

--- Determines if variant mode should be used
--- @param variantEnabled boolean Whether variant mode is enabled in settings
--- @return boolean True if variant mode should be used
local function shouldUseVariant(variantEnabled)
  local playerCount = #getSeatedPlayers()
  return variantEnabled or playerCount >= 6
end

--- Combines all bean decks into a single main deck
--- @param center table The center object for positioning
--- @param useVariant boolean Whether to include variant beans
--- @param callback function Called when deck is ready with the deck object
function GameStart.combineBeanDecks(center, useVariant, callback)
  log('Combining bean decks...')
  
  local centerPos = center.getPosition()
  local deckPosition = centerPos + Vector(-6, 2, 0) -- Left snap point position
  local cardRotation = center.getRotation() + Vector(0, 180, 0)
  
  -- Collect all cards to include
  local cardsToClone = {}
  
  for name, beanData in pairs(GuidList.BeanDecks) do
    if not useVariant and isVariantBean(name) then
      local beanCard = getObjectFromGUID(beanData.Guid)
      if beanCard then
        log('Excluding variant bean: ' .. name)
        beanCard.destruct()
      end
    else
      local beanCard = getObjectFromGUID(beanData.Guid)
      if beanCard then
        beanCard.locked = false
        beanCard.interactable = true
        table.insert(cardsToClone, {
          card = beanCard,
          name = name,
          count = beanData.Num
        })
      else
        log('WARNING: Bean card not found: ' .. name)
      end
    end
  end
  
  -- Clone all cards at once (much faster)
  local totalCardsExpected = 0
  for _, data in ipairs(cardsToClone) do
    totalCardsExpected = totalCardsExpected + data.count
    
    -- Position original card
    data.card.setPositionSmooth(deckPosition, false, true)
    data.card.setRotation(cardRotation)
    
    -- Clone remaining copies
    for i = 2, data.count do
      data.card.clone({
        position = deckPosition,
        snap_to_grid = false
      })
    end
  end
  
  log('Creating ' .. totalCardsExpected .. ' total cards...')
  
  -- Wait for deck to form (much shorter wait since we're not tracking individual clones)
  Wait.time(function()
    if callback then callback() end
  end, 1.5)
end

--- Flips and shuffles the main deck
--- @param deck table The deck to shuffle
function GameStart.shuffleDeck(deck)
  if not deck then
    log('ERROR: Cannot shuffle nil deck')
    return
  end
  
  log('Flipping deck face-down and shuffling...')
  
  -- Flip deck face down if it's face up
  if not deck.is_face_down then
    deck.flip()
  end
  
  -- Shuffle the deck
  deck.shuffle()
end

--- Deals cards to all seated players
--- @param deck table The deck to deal from
--- @param cardsPerPlayer number Number of cards to deal to each player
function GameStart.dealCards(deck, cardsPerPlayer)
  if not deck then
    log('ERROR: Cannot deal from nil deck')
    return
  end
  
  local seatedPlayers = getSeatedPlayers()
  log('Dealing ' .. cardsPerPlayer .. ' cards to ' .. #seatedPlayers .. ' players...')
  
  for _, playerColor in ipairs(seatedPlayers) do
    local playerData = GuidList.Players[playerColor]
    if playerData then
      -- Deal cards to player's hand
      for i = 1, cardsPerPlayer do
        Wait.time(function()
          if deck then
            deck.deal(1, playerColor)
          end
        end, (i - 1) * 0.15)
      end
      
      -- After all cards are dealt to this player, flip them face-up in their hand
      Wait.time(function()
        local hand = Player[playerColor].getHandObjects()
        for _, card in ipairs(hand) do
          if card.is_face_down then
            card.flip()
          end
        end
      end, cardsPerPlayer * 0.15 + 0.5)
    end
  end
end

--- Starts the game by combining, shuffling, and dealing cards
--- @param center table The center object
--- @param variantEnabled boolean Whether variant mode is enabled
--- @param cardsPerPlayer number Number of cards to deal (default: 5)
function GameStart.startGame(center, variantEnabled, cardsPerPlayer)
  cardsPerPlayer = cardsPerPlayer or 5
  
  local useVariant = shouldUseVariant(variantEnabled)
  
  if useVariant then
    log('Starting game in VARIANT mode (all beans included)')
  else
    log('Starting game in STANDARD mode (excluding Coffee, Cocoa, Wax)')
  end
  
  -- Combine all bean cards (excluding variant beans if needed)
  GameStart.combineBeanDecks(center, useVariant, function()
    -- Find the deck that formed
    local centerPos = center.getPosition()
    local deckPosition = centerPos + Vector(-6, 2, 0)
    local objectsAtPosition = Physics.cast({
      origin = deckPosition,
      direction = {0, 1, 0},
      type = 3,
      size = {2, 2, 2},
      max_distance = 0
    })
    
    local deck = nil
    for _, hit in ipairs(objectsAtPosition) do
      if hit.hit_object and (hit.hit_object.type == 'Deck' or hit.hit_object.type == 'Card') then
        deck = hit.hit_object
        break
      end
    end
    
    if deck then
      -- Flip and shuffle immediately
      GameStart.shuffleDeck(deck)
      
      -- Wait for shuffle animation, then deal
      Wait.time(function()
        GameStart.dealCards(deck, cardsPerPlayer)
      end, 1)
    else
      log('ERROR: Deck not found after combining')
    end
  end)
end

return GameStart

