-- math.lua
-- Extends the built in math lib.
--

-- Lua and the Playdate SDK have no built-in clamp.
--- Constrains value to [min, max]. Raises an error on invalid min, max values (e.g. max < min).
---@nodiscard
---@param value number
---@param min number
---@param max number
---@return number
function math.clamp(value, min, max)
  if min > max then
    error(string.format("Error - clamp: min (%s) must be less than max (%s)", min, max), 2)
  end

  if (value < min) then return min end
  if (value > max) then return max end
  return value
end
