local Constants = require('Bohnanza.src.util.constants')

State = {
  Enabled = false,
}

function toggleVariant()
  if State.Enabled then
    State.Enabled = false
    self.UI.setAttribute('toggleVariantButtonLabel', 'text', 'Enable Variant')
    self.UI.setAttribute('toggleVariantButton', 'color', 'red')
  else
    State.Enabled = true
    self.UI.setAttribute('toggleVariantButtonLabel', 'text', 'Disable Variant')
    self.UI.setAttribute('toggleVariantButton', 'color', 'green')
  end
end

function onSave()
  if Constants.DEBUG then
    return ''
  else
    return JSON.encode(State)
  end
end

function onLoad(script_state)
  if script_state ~= '' then
    State = JSON.decode(script_state)
  end
end
