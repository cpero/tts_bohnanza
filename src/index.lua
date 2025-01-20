require('vscode/console')

local Constants = require('src.util.constants')
local Functions = require('src.util.functions')
local DrawDeck = require('src.models.drawDeck')
local GuidList = require('src.util.guidList')

local State = {}

function onLoad(save_state)
	Functions.logFiller()
	log('Bohnanza onLoad called')
	print('Welcome to Bohnanza!')

	if save_state ~= '' then
		log('Loading save state')
		State = JSON.decode(save_state)
	end

	initScriptNames()
end

function initScriptNames()
	local StateChecker = getObjectFromGUID(GuidList.State)
	StateChecker.destruct()
	for _, Color in pairs(Constants.AvailableColors) do
		local ScriptLeft = getObjectFromGUID(GuidList.Players[Color].ScriptLeft)
		local ScriptMiddle = getObjectFromGUID(GuidList.Players[Color].ScriptMiddle)
		local ScriptRight = getObjectFromGUID(GuidList.Players[Color].ScriptRight)

		ScriptLeft.setName(Color .. ' Field Left')
		ScriptMiddle.setName(Color .. ' Field Middle')
		ScriptRight.setName(Color .. ' Field Right')
	end
end
