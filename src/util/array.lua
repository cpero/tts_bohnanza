--- Array Utility Functions
--- Helper functions for working with Lua tables as arrays

local ArrayObj = {}

--- Adds a value to the end of an array
--- @param array table The array to modify
--- @param value any The value to add
--- @return table The modified array
function ArrayObj.push(array, value)
  if not array then
    error('Array cannot be nil')
  end
  table.insert(array, value)
  return array
end

--- Removes and returns the first element from an array
--- @param array table The array to modify
--- @return any The removed element
--- @return table The modified array
function ArrayObj.shift(array)
  if not array then
    error('Array cannot be nil')
  end
  
  if #array == 0 then
    return nil, array
  end
  
  local element = table.remove(array, 1)
  return element, array
end

--- Removes and returns the last element from an array
--- @param array table The array to modify
--- @return any The removed element
--- @return table The modified array
function ArrayObj.pop(array)
  if not array then
    error('Array cannot be nil')
  end
  
  if #array == 0 then
    return nil, array
  end
  
  local element = table.remove(array)
  return element, array
end

--- Checks if an array contains a specific value
--- @param array table The array to search
--- @param value any The value to find
--- @return boolean True if the value is found
function ArrayObj.includes(array, value)
  if not array then
    return false
  end
  
  for _, element in ipairs(array) do
    if element == value then
      return true
    end
  end
  
  return false
end

--- Returns the index of a value in an array, or nil if not found
--- @param array table The array to search
--- @param value any The value to find
--- @return number|nil The index (1-based), or nil if not found
function ArrayObj.indexOf(array, value)
  if not array then
    return nil
  end
  
  for i, element in ipairs(array) do
    if element == value then
      return i
    end
  end
  
  return nil
end

--- Creates a shallow copy of an array
--- @param array table The array to copy
--- @return table A new array with the same elements
function ArrayObj.copy(array)
  if not array then
    return {}
  end
  
  local newArray = {}
  for i, element in ipairs(array) do
    newArray[i] = element
  end
  
  return newArray
end

--- Filters an array based on a predicate function
--- @param array table The array to filter
--- @param predicate function A function that returns true to keep an element
--- @return table A new array with filtered elements
function ArrayObj.filter(array, predicate)
  if not array then
    return {}
  end
  
  if not predicate then
    error('Predicate function cannot be nil')
  end
  
  local filtered = {}
  for _, element in ipairs(array) do
    if predicate(element) then
      table.insert(filtered, element)
    end
  end
  
  return filtered
end

--- Maps an array to a new array using a transform function
--- @param array table The array to map
--- @param transform function A function that transforms each element
--- @return table A new array with transformed elements
function ArrayObj.map(array, transform)
  if not array then
    return {}
  end
  
  if not transform then
    error('Transform function cannot be nil')
  end
  
  local mapped = {}
  for i, element in ipairs(array) do
    mapped[i] = transform(element)
  end
  
  return mapped
end

--- Gets the length of an array
--- @param array table The array
--- @return number The length of the array
function ArrayObj.length(array)
  if not array then
    return 0
  end
  return #array
end

--- Checks if an array is empty
--- @param array table The array to check
--- @return boolean True if the array is empty or nil
function ArrayObj.isEmpty(array)
  return not array or #array == 0
end

return ArrayObj
