local DrawDeck = {}

local Constants = require('src.util.constants')
local Functions = require('src.util.functions')
local State = require('src.models.state')

function DrawDeck.init()
  for _, Object in pairs(State.getObjectList().Decks.Standard) do
    Object.setInvisibleTo(Constants.AvailableColors)
  end

  for _, Object in pairs(State.getObjectList().Decks.Variant) do
    Object.setInvisibleTo(Constants.AvailableColors)
  end
end

function DrawDeck.StartGame()
  local PlayerCount = Functions.length(State.SeatedPlayers)
end

return DrawDeck
