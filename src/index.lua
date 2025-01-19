require('vscode/console')

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
	-- 	type = 'Checker_red',
	-- 	position = { 0, 10, 50 },
	-- 	scale = { 1, 1, 1 },
	-- 	rotation = { 0, 0, 0 }
	-- })
end

function onSave()
	log(State.getState())

	-- return JSON.encode(State)
	return ''
end
