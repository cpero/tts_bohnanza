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

-- function scaleUpBeanDecks()
-- 	log('Scaling up bean decks')
-- 	for _, Guid in pairs(GuidList.BeanDecks) do
-- 		local Deck = getObjectFromGUID(Guid)
-- 		Deck.setScale(Deck.getScale() * 1.5)
-- 	end
-- end

-- function scaleUpPlayerZones()
-- 	log('Scaling up player zones')
-- 	for Color, Player in pairs(GuidList.Players) do
-- 		local PosVector = {}
-- 		if Color == 'White' or Color == 'Red' or Color == 'Orange' then
-- 			PosVector = Vector(0, 0.5, 2)
-- 		elseif Color == 'Yellow' or Color == 'Blue' then
-- 			PosVector = Vector(-2, 0.5, 0)
-- 		elseif Color == 'Green' or Color == 'Purple' then
-- 			PosVector = Vector(2, 0.5, 0)
-- 		end

-- 		local HiddenZone = getObjectFromGUID(Player.HiddenZone)
-- 		HiddenZone.setScale(HiddenZone.getScale() + Vector(12, 0.5, 4))
-- 		HiddenZone.setPosition(HiddenZone.getPosition() + PosVector)
-- 		local HiddenSZone = getObjectFromGUID(Player.HiddenSZone)
-- 		HiddenSZone.setScale(HiddenSZone.getScale() + Vector(12, 0.5, 4))
-- 		HiddenSZone.setPosition(HiddenSZone.getPosition() + PosVector)
-- 	end
-- end

-- function movePlayerFields()
-- 	log('Moving player fields')
-- 	for Color, Player in pairs(GuidList.Players) do
-- 		local PosVector = {}
-- 		if Color == 'White' or Color == 'Red' or Color == 'Orange' then
-- 			PosVector = Vector(0, 0, 4)
-- 		elseif Color == 'Yellow' or Color == 'Blue' then
-- 			PosVector = Vector(-4, 0, 0)
-- 		elseif Color == 'Green' or Color == 'Purple' then
-- 			PosVector = Vector(4, 0, 0)
-- 		end

-- 		local FieldLeft = getObjectFromGUID(Player.FieldLeft)
-- 		FieldLeft.setPosition(FieldLeft.getPosition() + PosVector)
-- 		local FieldMiddle = getObjectFromGUID(Player.FieldMiddle)
-- 		FieldMiddle.setPosition(FieldMiddle.getPosition() + PosVector)
-- 		local FieldRight = getObjectFromGUID(Player.FieldRight)
-- 		FieldRight.setPosition(FieldRight.getPosition() + PosVector)
-- 	end
-- end
