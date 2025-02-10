local Constants = require("Bohnanza.src.util.constants")
local GuidList = require("Bohnanza.src.util.guidList")

local state = {
  started = false,
  variant = true
}

local center = getObjectFromGUID(GuidList.Center)

local whiteHand = getObjectFromGUID(GuidList.Players.White.Hand)
local orangeHand = getObjectFromGUID(GuidList.Players.Orange.Hand)
local greenHand = getObjectFromGUID(GuidList.Players.Green.Hand)
local yellowHand = getObjectFromGUID(GuidList.Players.Yellow.Hand)
local redHand = getObjectFromGUID(GuidList.Players.Red.Hand)
local pinkHand = getObjectFromGUID(GuidList.Players.Pink.Hand)
local purpleHand = getObjectFromGUID(GuidList.Players.Purple.Hand)

local rules = getObjectFromGUID(GuidList.Rules)

function setupGame()
  log('Setting up game...')
  initHands()
  initRules()
  initBeanDecks()
  initPlayerSpace()
end

function onLoad(script_state)
  if script_state ~= '' then
    state = JSON.decode(script_state)
  end
end

function onSave()
  if Constants.DEBUG then
    return ''
  else
    return JSON.encode(state)
  end
end

function initHands()
  log('Initializing player hands')
  orangeHand.setPosition(center.getPosition() + Vector(0, 3, -55))
  orangeHand.setRotation(center.getRotation())
  orangeHand.setScale(Vector(30, 5, 10))

  whiteHand.setPosition(orangeHand.getPosition() + Vector(-50, 0, 0))
  whiteHand.setRotation(orangeHand.getRotation())
  whiteHand.setScale(Vector(30, 5, 10))

  greenHand.setPosition(orangeHand.getPosition() + Vector(50, 0, 0))
  greenHand.setRotation(orangeHand.getRotation())
  greenHand.setScale(Vector(30, 5, 10))

  yellowHand.setPosition(center.getPosition() + Vector(76, 3, -10))
  yellowHand.setRotation(center.getRotation() + Vector(0, -90, 0))
  yellowHand.setScale(Vector(30, 5, 10))

  redHand.setPosition(yellowHand.getPosition() + Vector(0, 0, 45))
  redHand.setRotation(yellowHand.getRotation())
  redHand.setScale(Vector(30, 5, 10))

  pinkHand.setPosition(center.getPosition() + Vector(-76, 3, -10))
  pinkHand.setRotation(center.getRotation() + Vector(0, 90, 0))
  pinkHand.setScale(Vector(30, 5, 10))

  purpleHand.setPosition(pinkHand.getPosition() + Vector(0, 0, 45))
  purpleHand.setRotation(pinkHand.getRotation())
  purpleHand.setScale(Vector(30, 5, 10))
end

function initRules()
  log('Initializing rules')
  rules.setPosition(center.getPosition() + Vector(0, 30, 80))
  rules.setRotation(Vector(60.43, 180, 0))
  rules.locked = true
  rules.interactable = true
end

function initBeanDecks()
  log('Initializing bean decks')
  local decks = {
    Chili = getObjectFromGUID(GuidList.BeanDecks.Chili.Guid),
    Green = getObjectFromGUID(GuidList.BeanDecks.Green.Guid),
    Black = getObjectFromGUID(GuidList.BeanDecks.Black.Guid),
    Stink = getObjectFromGUID(GuidList.BeanDecks.Stink.Guid),
    Soy = getObjectFromGUID(GuidList.BeanDecks.Soy.Guid),
    Red = getObjectFromGUID(GuidList.BeanDecks.Red.Guid),
    Garden = getObjectFromGUID(GuidList.BeanDecks.Garden.Guid),
    Blue = getObjectFromGUID(GuidList.BeanDecks.Blue.Guid),
    Coffee = getObjectFromGUID(GuidList.BeanDecks.Coffee.Guid),
    Cocoa = getObjectFromGUID(GuidList.BeanDecks.Cocoa.Guid),
    Wax = getObjectFromGUID(GuidList.BeanDecks.Wax.Guid)
  }

  local xPos = -40

  for name, deck in pairs(decks) do
    deck.setPosition(center.getPosition() + Vector(xPos, 1, 50))
    deck.setRotation(center.getRotation() + Vector(0, 180, 0))
    -- deck.interactable = false
    -- deck.locked = true
    xPos = xPos + 8
  end
end

function initPlayerSpace()
  log('Initializing player space')
  for color, playerObj in pairs(GuidList.Players) do
    local hand = getObjectFromGUID(playerObj.Hand)
    local posVector = Vector(0, 0, 0)
    local yValue = -3

    if color == 'White' or color == 'Green' or color == 'Orange' then
      posVector = Vector(0, yValue, 8)
    elseif color == 'Purple' or color == 'Pink' then
      posVector = Vector(8, yValue, 0)
    else
      posVector = Vector(-8, yValue, 0)
    end

    local scoreCounter = getObjectFromGUID(playerObj.Score)
    scoreCounter.interactable = Constants.DEBUG
    scoreCounter.locked = true
    scoreCounter.setPosition(hand.getPosition() + posVector)


    local leftPosVector = nil
    local middlePosVector = nil
    local rightPosVector = nil

    if color == 'White' or color == 'Green' or color == 'Orange' then
      leftPosVector = Vector(-10, yValue, 15)
      middlePosVector = Vector(0, yValue, 15)
      rightPosVector = Vector(10, yValue, 15)
    elseif color == 'Purple' or color == 'Pink' then
      leftPosVector = Vector(15, yValue, 10)
      middlePosVector = Vector(15, yValue, 0)
      rightPosVector = Vector(15, yValue, -10)
    else
      leftPosVector = Vector(-15, yValue, 10)
      middlePosVector = Vector(-15, yValue, 0)
      rightPosVector = Vector(-15, yValue, -10)
    end

    local leftField = getObjectFromGUID(playerObj.LeftField)
    leftField.interactable = Constants.DEBUG
    leftField.locked = true
    leftField.setPosition(hand.getPosition() + leftPosVector)
    leftField.setRotation(hand.getRotation())


    local middleField = getObjectFromGUID(playerObj.MiddleField)
    middleField.interactable = Constants.DEBUG
    middleField.locked = true
    middleField.setPosition(hand.getPosition() + middlePosVector)
    middleField.setRotation(hand.getRotation())


    local rightField = getObjectFromGUID(playerObj.RightField)
    rightField.interactable = Constants.DEBUG
    rightField.locked = true
    rightField.setPosition(hand.getPosition() + rightPosVector)
    rightField.setRotation(hand.getRotation())
  end
end

function onClickStartGame()
  log('Starting game...')
end

function onClickToggleVariant()
  state.variant = not state.variant
  log(state.variant)
  if state.variant then
    self.UI.setAttribute('toggleVariantBtn', 'text', 'Variant Mode: Enabled')
    self.UI.setAttribute('toggleVariantBtn', 'color', 'green')
  else
    self.UI.setAttribute('toggleVariantBtn', 'text', 'Variant Mode: Disabled')
    self.UI.setAttribute('toggleVariantBtn', 'color', 'red')
  end
end

function onPlayerChangeColor()
  if #getSeatedPlayers() >= 6 then
    self.UI.setAttribute('toggleVariantBtn', 'text', 'Variant Mode: Enabled')
    self.UI.setAttribute('toggleVariantBtn', 'color', 'green')
    self.UI.setAttribute('toggleVariantBtn', 'interactable', 'false')
    state.variant = true
  else
    self.UI.setAttribute('toggleVariantBtn', 'interactable', 'true')
  end
end
