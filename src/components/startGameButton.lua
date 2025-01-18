local StartGameButton = {}

local ScriptingZoneManager = require('src.managers.scriptingZoneManager')
local CounterManager = require('src.managers.counterManager')

local drawDeck
local State
local ObjectList

--- Creates the button used to start the game script
---@param GObjectList table The global list of objest
---@param GState table The global state of the game
function StartGameButton.create(GObjectList, GState)
	ObjectList = GObjectList
	State = GState

	drawDeck = ObjectList.ScriptDrawDeck;
	drawDeck.createButton({
		click_function = 'onClick',
		label = 'Start Game',
		tooltip = 'Click me once all players are seated!',
		rotation = { 0, 180, 0 },
		width = 1000,
		height = 100,
		position = { 0.5, -0.45, 0 },
	})
end

function onClick(_, _, _)
	log('Start Game button clicked')

	State.SeatedPlayers = getSeatedPlayers()
	State.Started = true

	ScriptingZoneManager.StartGame(ObjectList, State)
	CounterManager.StartGame(ObjectList, State)

	drawDeck.clearButtons()
end

return StartGameButton
