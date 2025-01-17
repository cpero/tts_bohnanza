require('vscode/console')

local Constants = require('src.util.constants')
local GuidList = require('src.util.guidList')
local Functions = require('src.util.functions')

local StartGameButton = require('src.components.startGameButton')

local ObjectList = {}
local State = {
	Init = false,
	Started = false,
	SeatedPlayers = {}
}

function onLoad(save_state)
	Functions.printLogFiller()
	log('Bohnanza onLoad called')
	print('Welcome to Bohnanza!')

	if save_state ~= '' then
		log('Loading save state')
		State = JSON.decode(save_state)
	end

	loadObjects()

	if not State.Init then
		StartGameButton.create(ObjectList, State)
		State.Init = true
	end
end

function onSave()
	-- return JSON.encode(State)
	return ''
end

function loadObjects()
	ObjectList.Decks = {}
	for DeckName, Guid in pairs(GuidList.Decks) do
		ObjectList.Decks[DeckName] = getObjectFromGUID(Guid)
	end

	ObjectList.Players = {}
	for _, Color in ipairs(Constants.AvailableColors) do
		ObjectList.Players[Color] = {}
		ObjectList.Players[Color]['Hand'] =
				getObjectFromGUID(GuidList.Players[Color].Hand)
		ObjectList.Players[Color]['ScriptLeft'] =
				getObjectFromGUID(GuidList.Players[Color].ScriptLeft)
		ObjectList.Players[Color]['ScriptMiddle'] =
				getObjectFromGUID(GuidList.Players[Color].ScriptMiddle)
		ObjectList.Players[Color]['ScriptRight'] =
				getObjectFromGUID(GuidList.Players[Color].ScriptRight)
	end

	ObjectList.ScriptDiscardDeck = getObjectFromGUID(GuidList.ScriptDiscardDeck)
	ObjectList.ScriptDrawDeck = getObjectFromGUID(GuidList.ScriptDrawDeck)
end
