require('vscode/console')

local GuidList = require('src.util.guidList')
local Constants = require('src.util.constants')

local State = {
	Started = false,
}

function onSave()
	-- return JSON.encode(State)

	-- log(JSON.encode(State))
	return '';
end

function onLoad(script_state)
	log('Loading Bohnanza state')
	if script_state ~= '' then
		log('Found saved game')
		State = JSON.decode(script_state)
	else
		log('No saved game found')
		initializeTable()
		-- removeLayoutZones()
		-- createScriptingZoneForHands()
	end
end

function initializeTable()
	log('Initializing table')
	initializeBeanDecks()
end

function removeLayoutZones()
	log('Removing layout zones')
	for _, Player in pairs(GuidList.Players) do
		local Zone = getObjectFromGUID(Player.LayoutZone)
		Zone.destruct()
	end
end

function createScriptingZoneForHands()
	log('Creating scripting zones for hands')
	for Color, Player in pairs(GuidList.Players) do
		local Zone = getObjectFromGUID(Player.HiddenZone)
		local scriptingZone = spawnObject({
			type = 'ScriptingTrigger',
			position = Zone.getPosition(),
			rotation = Zone.getRotation(),
			scale = Zone.getScale(),
		})
		scriptingZone.setName(Color .. 'HandScriptingZone')
	end
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
