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
	end
end

function initializeTable()
	log('Initializing table')
	initializeBeanDecks()
	initializePlayerLayouts()
end

function initializePlayerLayouts()
	Hands.enable = false
	Hands.hiding = 3

	for _, PlayerColor in pairs(Constants.AvailableColors) do
		local Player = getObjectFromGUID(GuidList.Players[PlayerColor].Hand)

		local PositionVector = nil
		local ScaleVector = nil
		local RotationVector = nil
		if PlayerColor == 'White' or PlayerColor == 'Red' or PlayerColor == 'Orange' then
			PositionVector = Vector(0, 0, 15)
			RotationVector = Vector(0, 0, 0)
			ScaleVector = Vector(20, 1.5, 1.5)
		elseif PlayerColor == 'Blue' or PlayerColor == 'Yellow' then
			PositionVector = Vector(-15, 0, 00)
			RotationVector = Vector(0, 0, 0)
			ScaleVector = Vector(20, 1.5, 1.5)
		elseif PlayerColor == 'Purple' or PlayerColor == 'Green' then
			PositionVector = Vector(15, 0, 0)
			RotationVector = Vector(0, 0, 0)
			ScaleVector = Vector(20, 1.5, 1.5)
		end

		local LayoutZone = spawnObject({
			type = 'LayoutZone',
			position = Player.getPosition() + PositionVector,
			rotation = Player.getRotation() + RotationVector,
			scale = Player.getScale() + ScaleVector,
		})

		local HiddenZone = spawnObject({
			type = 'FogOfWarTrigger',
			position = Player.getPosition() + PositionVector,
			rotation = Player.getRotation() + RotationVector,
			scale = Player.getScale() + ScaleVector,
		})

		Wait.frames(function()
			LayoutZone.LayoutZone.setOptions({
				allow_swapping = false,
				alternate_direction = false,
				combine_into_decks = false,
				new_object_facing = 1,
				max_objects_per_group = 200,
				max_objects_per_new_group = 0,
				horizontal_group_padding = 0,
				horizontal_spread = 2,
				meld_sort = 0,
				meld_direction = 0,
				meld_sort_existing = true,
				randomize = false,
				split_added_decks = true,
				sticky_cards = true,
				direction = 1
			})
		end, 5)
	end
end

function initializeBeanDecks()
	log('Initializing bean decks')
	local PosCounter = 0
	local Table = getObjectFromGUID(GuidList.Table)
	for _, Guid in pairs(GuidList.BeanDecks) do
		local Deck = getObjectFromGUID(Guid)
		Deck.setPosition(Table.getPosition() + Vector((PosCounter * 6) - 28, 2, 50))
		Deck.setScale(Vector(2.5, 2.5, 2.5))
		PosCounter = PosCounter + 1
	end
end
