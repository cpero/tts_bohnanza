require('vscode/console')

local GuidList = require('Bohnanza.src.util.guidList')
local Constants = require('Bohnanza.src.util.constants')

local State = {
	Started = false,
	DrawZone = '',
	CurrentDrawDeck = '',
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
	for Name, Object in pairs(GuidList.BeanDecks) do
		local Deck = getObjectFromGUID(Object.Guid)
		Deck.setPosition(Table.getPosition() + Vector((PosCounter * 6) - 28, -2, 50))
		Deck.setScale(Vector(1.5, 1.5, 1.5))
		PosCounter = PosCounter + 1
		Deck.setName(Name)
		Deck.setTags({ Name, 'Card' })
		Deck.locked = true
		Deck.interactable = false
	end
end

function startGame()
	log('Starting game')

	Turns.enable = true
	Turns.order = getSeatedPlayers()
	Turns.turn_color = getSeatedPlayers()[math.random(1, #getSeatedPlayers())]

	createDecks()

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

function createDecks()
	log('Creating decks')
	local DrawDeck = getObjectFromGUID(GuidList.DrawDeck)
	local DiscardDeck = getObjectFromGUID(GuidList.DiscardDeck)

	DrawDeck.UI.setXml([[<Panel position="0 0 -46" rotation="0 0 0" color="#212131" width="350" height="450" />]])
	DrawDeck.setSnapPoints({
		{
			position = { 0, 0, 0 },
			rotation = { 0, 180, 0 },
			rotation_snap = true
		},
	})

	local DrawZone = spawnObject({
		type     = 'ScriptingTrigger',
		position = DrawDeck.getPosition() + Vector(0, 2, 0),
		rotation = DrawDeck.getRotation(),
		scale    = DrawDeck.getScale() + Vector(5, 5, 5),
	})

	State.DrawZone = DrawZone.getGUID()

	DiscardDeck.UI.setXml([[<Panel position="0 0 -46" rotation="0 0 0" color="#212131" width="350" height="450">
		<Text fontSize='30' color='White' >DISCARD</Text>
	</Panel>]])
	DiscardDeck.setSnapPoints({
		{
			position = { 0, 0, 0 },
			rotation = { 0, 180, 0 },
			rotation_snap = true
		},
	})
	-- DiscardDeck.createButton({
	-- 	click_function = 'shuffleDeck',
	-- 	function_owner = self,
	-- 	label = 'Shuffle',
	-- 	position = { 0, 0.5, -4 },
	-- 	rotation = { 0, 180, 0 },
	-- 	width = 1700,
	-- 	height = 500,
	-- 	font_size = 150,
	-- 	color = 'White',
	-- 	tooltip = 'Shuffle the discard pile back into the draw deck',
	-- })

	createDrawDeck()
end

function createDrawDeck()
	log('Creating draw deck')

	local DrawZone = getObjectFromGUID(State.DrawZone)
	local IsVariant = getObjectFromGUID(GuidList.Buttons.ToggleVariant).getTable('State').Enabled

	for Name, Object in pairs(GuidList.BeanDecks) do
		if (Name == 'Coffee' or Name == 'Cocoa' or Name == 'Wax') and not IsVariant then
			log('Skipping ' .. Name)
			-- Skip variant beans
		else
			for i = 1, Object.Num do
				local NewObject = getObjectFromGUID(Object.Guid).clone({
					position = DrawZone.getPosition() + Vector(0, 2, 0),
				})
				NewObject.locked = false
				NewObject.interactable = true
				DrawZone.putObject(NewObject)
			end
		end
	end

	Wait.frames(function()
		for _, Object in ipairs(DrawZone.getObjects()) do
			if Object.type == 'Deck' then
				State.CurrentDrawDeck = Object.getGUID()
				Object.shuffle()
				Object.flip()
				break
			end
		end
	end, 30)
end

function resetBoard()
	for _, Color in ipairs(getSeatedPlayers()) do
		local Zone = GuidList.Players[Color]
		for Name, Guid in pairs(Zone) do
			local Component = getObjectFromGUID(Guid)
			Component.setPosition(Component.getPosition() + Vector(0, -10000, 0))

			if string.find(Name, 'Field') then
				Component.call('initializeField', nil)
			end
		end
	end

	for _, Guid in pairs(GuidList.Buttons) do
		local Button = getObjectFromGUID(Guid)
		Button.setPosition(Button.getPosition() + Vector(0, 10000, 0))
	end
end
