-- time.lua
-- Handles single source of truth for current time and delta time.
--

import "engine/math"

local MAX_DELTA_TIME_MS <const> = 100
local delta_time_ms, current_time_ms = 0, 0

Time = {}

--- Initialise Time values (delta time and current time).
function Time.init()
  delta_time_ms = 0
  current_time_ms = playdate.getCurrentTimeMilliseconds()
end

--- Update delta time and current time.
function Time.tick()
  local new_time_ms = playdate.getCurrentTimeMilliseconds()
  delta_time_ms = new_time_ms - current_time_ms
  delta_time_ms = math.clamp(delta_time_ms, 0, MAX_DELTA_TIME_MS)

  current_time_ms = new_time_ms
end

--- Returns current time (ms).
---@return integer
function Time.getCurrentTime() return current_time_ms end

--- Returns delta time (ms).
---@return integer
function Time.getDeltaTime() return delta_time_ms end
