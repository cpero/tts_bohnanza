local Functions = {}

function Functions.logFiller()
	log('--------------------------------------------------')
end

---Check if a table contains a value
---@param table table
---@param val string | integer
---@return boolean
function Functions.hasValue(table, val)
	for value in pairs(table) do
		if value == val then
			return true
		end
	end

	return false
end

---Get the length of a table
---@param table table
---@return integer
function Functions.length(table)
	local count = 0
	for _ in pairs(table) do
		count = count + 1
	end
	return count
end

---Find the player color based on a provided GUID
---@param ObjectList table
---@param ObjectGuid string
---@return string
function Functions.findColorFromObject(ObjectList, ObjectGuid)
	local FoundColor = ""
	for Color, Player in pairs(ObjectList.Players) do
		if FoundColor == "" then
			for _, Value in pairs(Player) do
				if Value.getGUID() == ObjectGuid then
					FoundColor = Color
				end
			end
		end
	end
	return FoundColor
end

return Functions
