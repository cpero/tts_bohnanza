local GuidList = require "Bohnanza.src.util.guidList"
local Constants = require "Bohnanza.src.util.constants"
require("vscode/console")


local state = {
	stage = 1,
	seatedPlayers = {},
}

function onLoad(script_state)
	if script_state ~= '' then
		state = JSON.decode(script_state)
		log('Found state. Loading...')
	end
	local center = getObjectFromGUID(GuidList.Center)

	if state.stage == 1 then
		center.call('setupGame')
		state.stage = 2
		log('Game setup called')
	end
end

function onSave()
	if Constants.DEBUG then
		return ''
	else
		return JSON.encode(state)
	end
end
