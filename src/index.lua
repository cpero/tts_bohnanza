require('vscode/console')

local Constants = require('src.util.constants')
local Functions = require('src.util.functions')
local DrawDeck = require('src.models.drawDeck')
local StartGameButton = require('src.components.startGameButton')
local State = require('src.models.state')

function onLoad(save_state)
	Functions.logFiller()
	log('Bohnanza onLoad called')
	print('Welcome to Bohnanza!')

	if save_state ~= '' then
		log('Loading save state')
		State = JSON.decode(save_state)
	end

	State.loadObjectList()

	if not State.Init then
		DrawDeck.init()
		StartGameButton.init()
		State.updateValue('Init', true)
	end

	-- spawnObject({
	-- 	type = 'Checker_black',
	-- 	position = State.getObjectList().Buttons.StartGame.getPosition() + Vector(0, 0.5, -10),
	-- 	scale = State.getObjectList().Buttons.StartGame.getScale(),
	-- 	rotation = State.getObjectList().Buttons.StartGame.getRotation()
	-- })
end

function onSave()
	log(State.getState())

	-- return JSON.encode(State)
	return ''
end
