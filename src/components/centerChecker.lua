local Constants = require("Bohnanza.src.util.constants")
local GuidList = require("Bohnanza.src.util.guidList")

local state = {
  stage = 1
}

local center = getObjectFromGUID(GuidList.Center)
local whiteHand = getObjectFromGUID(GuidList.Hands.White)
local orangeHand = getObjectFromGUID(GuidList.Hands.Orange)
local greenHand = getObjectFromGUID(GuidList.Hands.Green)
local yellowHand = getObjectFromGUID(GuidList.Hands.Yellow)
local redHand = getObjectFromGUID(GuidList.Hands.Red)
local pinkHand = getObjectFromGUID(GuidList.Hands.Pink)
local purpleHand = getObjectFromGUID(GuidList.Hands.Purple)
local rules = getObjectFromGUID(GuidList.Rules)

function setupGame()
  log('Setting up game...')
  initHands()
  initRules()
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
  orangeHand.setPosition(center.getPosition() + Vector(0, 4, -55))
  orangeHand.setRotation(center.getRotation())
  whiteHand.setPosition(orangeHand.getPosition() + Vector(-50, 0, 0))
  whiteHand.setRotation(orangeHand.getRotation())
  greenHand.setPosition(orangeHand.getPosition() + Vector(50, 0, 0))
  greenHand.setRotation(orangeHand.getRotation())

  yellowHand.setPosition(center.getPosition() + Vector(76, 4, -10))
  yellowHand.setRotation(center.getRotation() + Vector(0, 90, 0))
  redHand.setPosition(yellowHand.getPosition() + Vector(0, 0, 45))
  redHand.setRotation(yellowHand.getRotation())

  pinkHand.setPosition(center.getPosition() + Vector(-76, 4, -10))
  pinkHand.setRotation(center.getRotation() + Vector(0, 90, 0))
  purpleHand.setPosition(pinkHand.getPosition() + Vector(0, 0, 45))
  purpleHand.setRotation(pinkHand.getRotation())
end

function initRules()
  rules.setPosition(center.getPosition() + Vector(0, 30, 80))
  rules.setRotation(Vector(60.43, 180, 0))
  rules.locked = true
  rules.interactable = true
end
