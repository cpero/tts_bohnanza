local Panels = {}

function Panels.StartGame(ObjectList, State)
	for _, Color in ipairs(State.SeatedPlayers) do
		Panels.showPanels(ObjectList, Color)
	end
end

---Hide panels for a Color
---@param ObjectList table
---@param Color string
function Panels.hidePanels(ObjectList, Color)
	-- local PanelLeft = ObjectList.Players[Color]['PanelLeft']
	-- local PanelMiddle = ObjectList.Players[Color]['PanelMiddle']
	-- local PanelRight = ObjectList.Players[Color]['PanelRight']

	-- PanelLeft.setPosition({ 0, 0, -1 })
	-- PanelMiddle.setPosition({ 0, 0, -1 })
	-- PanelRight.setPosition({ 0, 0, -1 })
end

---Show panels for a Color
---@param ObjectList table
---@param Color string
function Panels.showPanels(ObjectList, Color)
	-- local PanelLeft = ObjectList.Players[Color]['PanelLeft']
	-- local PanelMiddle = ObjectList.Players[Color]['PanelMiddle']
	-- local PanelRight = ObjectList.Players[Color]['PanelRight']

	-- PanelLeft.setPosition({ 0, 0, 1 })
	-- PanelMiddle.setPosition({ 0, 0, 1 })
	-- PanelRight.setPosition({ 0, 0, 1 })
end

return Panels
