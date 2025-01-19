local State = {}

local Constants = require('src.util.constants')
local GuidList = require('src.util.guidList')

local GState = {
  Init = false,
  Started = false,
  Variant = false,
  SeatedPlayers = {},
  Counters = {},
}

local GObjectList = {}

function State.setObjectList(ObjectList)
  GObjectList = ObjectList
end

function State.getObjectList()
  return GObjectList
end

function State.loadObjectList()
  GObjectList.Decks = {
    Standard = {},
    Variant = {}
  }

  for DeckName, Guid in pairs(GuidList.Decks.Stanard) do
    GObjectList.Decks.Standard[DeckName] = getObjectFromGUID(Guid)
  end

  for DeckName, Guid in pairs(GuidList.Decks.Variant) do
    GObjectList.Decks.Variant[DeckName] = getObjectFromGUID(Guid)
  end

  GObjectList.Players = {}
  for _, Color in ipairs(Constants.AvailableColors) do
    GObjectList.Players[Color] = {}
    GObjectList.Players[Color]['Hand'] =
        getObjectFromGUID(GuidList.Players[Color].Hand)
    GObjectList.Players[Color]['ScriptLeft'] =
        getObjectFromGUID(GuidList.Players[Color].ScriptLeft)
    GObjectList.Players[Color]['ScriptMiddle'] =
        getObjectFromGUID(GuidList.Players[Color].ScriptMiddle)
    GObjectList.Players[Color]['ScriptRight'] =
        getObjectFromGUID(GuidList.Players[Color].ScriptRight)
  end

  GObjectList.ScriptDiscardDeck = getObjectFromGUID(GuidList.ScriptDiscardDeck)
  GObjectList.ScriptDrawDeck = getObjectFromGUID(GuidList.ScriptDrawDeck)
  GObjectList.State = getObjectFromGUID(GuidList.State)

  GObjectList.Buttons = {}
  for ButtonName, Guid in pairs(GuidList.Buttons) do
    GObjectList.Buttons[ButtonName] = getObjectFromGUID(Guid)
  end

  GObjectList.Table = getObjectFromGUID(GuidList.Table)

  initHiddenObjects()
end

function initHiddenObjects()
  GObjectList.State.setInvisibleTo(Constants.AvailableColors)
  GObjectList.State.setName('State Checker')
  GObjectList.State.locked = true
  GObjectList.State.interactable = false
end

function State.setState(GState)
  State = GState
end

function State.getState()
  getButtonState()
  return GState
end

function getButtonState()
  GState.Started = getObjectFromGUID(GuidList.Buttons.StartGame).UI.getAttribute('StartGameButton', 'active') == 'false'
  GState.Variant = getObjectFromGUID(GuidList.Buttons.VariantToggle).UI.getAttribute('VariantToggleButton', 'color') ==
      'Green'
end

function State.updateValue(key, value)
  GState[key] = value
end

function State.initializeCounterColor(value)
  GState.Counters[value] = {}
end

function State.updateCounterValue(Color, Key, Value)
  GState.Counters[Color][Key] = Value
end

return State
