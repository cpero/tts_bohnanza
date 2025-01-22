local ArrayObj = {}

function ArrayObj.push(Array, Value)
  table.insert(Array, Value)
end

function ArrayObj.pop(Array)
  local el = table.remove(Array, 1)
  Array = ArrayObj.trim(Array)
  return { el, Array }
end

function ArrayObj.includes(Array, Value)
  for _, Element in pairs(Array) do
    if Element == Value then
      return true
    end
  end
  return false
end

function ArrayObj.trim(Array)
  local TrimmedArray = {}
  if #Array > 0 then
    for i = 1, #Array do
      table.insert(TrimmedArray, Array[i])
    end
  else
    return {}
  end
  return TrimmedArray
end

return ArrayObj
