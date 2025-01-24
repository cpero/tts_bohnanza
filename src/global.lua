require('vscode/console')

local GuidList = require('Bohnanza.src.util.guidList')
local Constants = require('Bohnanza.src.util.constants')

local State = {
	Started = false,
}

function onSave()
	if Constants.DEBUG then
		return ''
	else
		return JSON.encode(State)
	end
end

function onLoad(script_state)
	log('Loading Bohnanza state')
	if script_state ~= '' then
		log('Found saved game')
		State = JSON.decode(script_state)
	else
		log('No saved game found')
		initializeTable()
	end
end

function initializeTable()
	log('Initializing table')
	initializeBeanDecks()
end

function initializeBeanDecks()
	log('Initializing bean decks')
	local PosCounter = 0
	local Table = getObjectFromGUID(GuidList.Table)
	for _, Guid in pairs(GuidList.BeanDecks) do
		local Deck = getObjectFromGUID(Guid)
		Deck.setPosition(Table.getPosition() + Vector((PosCounter * 6) - 28, 2, 50))
		Deck.setScale(Vector(1.5, 1.5, 1.5))
		PosCounter = PosCounter + 1
	end
end
