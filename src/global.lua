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

		if not State.Started or Constants.DEBUG then
			initializeTable()
		end
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

function startGame()
	log('Starting game')
	for _, Color in ipairs(getSeatedPlayers()) do
		local Zone = GuidList.Players[Color]
		for Name, Guid in pairs(Zone) do
			local Component = getObjectFromGUID(Guid)
			Component.setPosition(Component.getPosition() + Vector(0, 10000, 0))

			if string.find(Name, 'Field') then
				Component.call('initializeField', nil)
			end
		end
	end

	for _, Guid in pairs(GuidList.Buttons) do
		local Button = getObjectFromGUID(Guid)
		Button.setPosition(Button.getPosition() + Vector(0, -10000, 0))
	end

	local ToggleVariantButton = getObjectFromGUID(GuidList.Buttons.ToggleVariant)
	log(ToggleVariantButton.getTable('State'))
end
