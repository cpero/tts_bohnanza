local Array = require('Bohnanza.src.util.array')
local Constants = require('Bohnanza.src.util.constants')

local State = {
  CardList = {},
  Arranging = false
}

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

function onObjectEnterZone(Zone, Object)
  if Zone.guid == self.guid then
    if Object.type == 'Deck' then
      for _, Card in pairs(Object.getObjects()) do
        pushCard(Card)
      end
    elseif Object.type == 'Card' then
      pushCard(Object)
    end
  end
end

function onObjectLeaveZone(Zone, Object)
  if Zone.guid == self.guid then
    if Object.type == 'Card' then
      local popped = popCard()
      State.CardList = popped[2]
    end
  end
end

function pushCard(Card)
  if not Array.includes(State.CardList, Card.guid) then
    Array.push(State.CardList, Card.guid)
  end
end

function popCard()
  arrangeCards()
  return Array.pop(State.CardList)
end

function arrangeCards()
  if State.Arranging then
    return
  end
  Wait.frames(function()
    State.Arranging = true
    for i, CardGuid in ipairs(State.CardList) do
      local Card = getObjectFromGUID(CardGuid)
      if Card ~= nil then
        Card.locked = true
        Card.interactable = false
        Card.setPositionSmooth(self.getPosition() + Vector((-2 * i) + 10, (i * -0.1) + 1, 0), false)
      end
    end
  end, 30)
  Wait.frames(function()
    for _, CardGuid in ipairs(State.CardList) do
      local Card = getObjectFromGUID(CardGuid)
      if Card ~= nil then
        Card.locked = false
        Card.interactable = true
      end
    end
    State.Arranging = false
  end, 120)
end
