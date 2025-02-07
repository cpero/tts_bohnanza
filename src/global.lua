local GuidList = require "Bohnanza.src.util.guidList"
local Constants = require "Bohnanza.src.util.constants"

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
	end
end

function onSave()
	if Constants.DEBUG then
		return ''
	else
		return JSON.encode(state)
	end
end
