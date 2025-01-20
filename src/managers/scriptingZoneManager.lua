-- local ScriptingZoneManager = {}

-- local PlayerField = require('src.models.playerField')
-- local Functions = require('src.util.functions')
-- local GuidList = require('src.util.guidList')
-- local State = {}

-- function ScriptingZoneManager.StartGame()
--   for _, Color in ipairs(getSeatedPlayers()) do
--     createPlayerFields(Color)
--   end
-- end

-- function createPlayerFields(Color)
--   local Player = getObjectFromGUID(GuidList.Players[Color].Player)

--   local ScriptLeft = Player.ScriptLeft
--   local ScriptMiddle = Player.ScriptMiddle
--   local ScriptRight = Player.ScriptRight

--   PlayerField.createField(Color, ScriptLeft, true)
--   PlayerField.createField(Color, ScriptMiddle, true)
--   PlayerField.createField(Color, ScriptRight, Functions.length(getSeatedPlayers()) < 4)
-- end

-- return ScriptingZoneManager
