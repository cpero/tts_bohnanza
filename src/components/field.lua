local Constants = require('Bohnanza.src.util.constants')

local State = {}

function onLoad(script_state)
  if script_state ~= '' then
    State = JSON.decode(script_state)
  end
end

function onSave()
  if Constants.DEBUG then
    return ''
  else
    return JSON.encode(State)
  end
end
