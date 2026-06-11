-- Lua and the Playdate SDK have no built-in clamp
function math.clamp(value, min, max)
  if min > max then
    error(string.format("clamp: min (%s) must be less than max (%s)", min, max), 2)
  end

  if (value < min) then return min end
  if (value > max) then return max end
  return value
end
