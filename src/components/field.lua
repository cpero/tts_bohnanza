local Constants = require('Bohnanza.src.util.constants')

local state = {
  init = false,
  locked = true,
  color = '',
  position = '',
}

function onLoad(script_state)
  if script_state ~= '' then
    state = JSON.decode(script_state)
  end

  if not state.init then
    state.init = true

    local color = string.gsub(self.getName(), 'LeftField', '')
    color = string.gsub(color, 'MiddleField', '')
    color = string.gsub(color, 'RightField', '')
    state.color = color

    local position = string.gsub(self.getName(), 'Field', '')
    position = string.gsub(position, color, '')
    state.position = position

    if position == 'Right' then
      self.UI.setAttribute('field', 'color', Constants.LockedFieldColor)
      state.locked = true
      self.UI.setAttribute('unlockFieldBtn', 'active', true)
    else
      unlockField()
    end
  end
end

function onSave()
  if Constants.DEBUG then
    return ''
  else
    return JSON.encode(state)
  end
end

function onClickUnlockField(player)
  if player.color ~= state.color then
    broadcastToColor('You cannot unlock a field that is not yours.', player.color)
  else
    unlockField()
  end
end

function unlockField()
  self.UI.setAttribute('unlockFieldBtn', 'active', false)
  self.UI.setAttributes('field', {
    color = Constants.UnlockedFieldColors[state.color],
  })
  state.locked = false
  self.setSnapPoints({ { position = { 0, 0, 0 }, rotation = { 0, 0, 0 }, rotation_snap = true } })
end
