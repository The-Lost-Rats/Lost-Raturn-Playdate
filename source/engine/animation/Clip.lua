-- Clip.lua
-- Immutable animation data: an ordered collection of image table frames
-- with per-frame durations, loop modes, and optional frame tagged events.
--

import "CoreLibs/object"

---@enum LoopMode
LOOP_MODE = {
  ONCE = "once",
  LOOP = "loop",
  PINGPONG = "pingpong",
}

--#region _____________________________  Locals  _____________________________

--- Validate duration is a positive number. Throws error if less than or equal to zero.
---@param duration number
local function validateDuration(duration)
  if duration <= 0 then error("Error - Clip: duration must be > 0, but was " .. duration, 2) end
end

--- Validate position is valid for a given size. Throws error if less than 1 or greater than size.
---@param position integer
---@param size integer
---@param function_name string
local function validatePosition(position, size, function_name)
  if position < 1 or position > size then
    error(
      "Error - Clip:"
        .. function_name
        .. " attempted to access an invalid position "
        .. position
        .. " not in range [1, "
        .. size
        .. "]",
      2
    )
  end
end

--- Returns a per frame duration list. Accepts one value for all frames or a list of durations.
--- The list of durations must match the frame count.
---@param durations number | number[]
---@param frame_count integer
---@return number[]
local function normalizeDurations(durations, frame_count)
  local duration_list = {}

  -- Handle single duration value
  if type(durations) == "number" then
    validateDuration(durations)

    for i = 1, frame_count do
      duration_list[i] = durations
    end

  -- Handle list of durations
  else
    if #durations ~= frame_count then
      error(
        "Error - Clip: durations count ("
          .. #durations
          .. ") must match frame count ("
          .. frame_count
          .. ")",
        2
      )
    end

    for i = 1, #durations do
      validateDuration(durations[i])
      duration_list[i] = durations[i]
    end
  end

  return duration_list
end
--#endregion

---@class ClipConfig
---@field imagetable _ImageTable source sheet
---@field frames integer[] imagetable cell indices in play order (1 indexed)
---@field durations number | number[] one value for all frames or a value per frame (in ms)
---@field loop? LoopMode defaults to ONCE
---@field events? table<integer, string> clip position (1 indexed) to event name

---@class Clip: _Object
---@field private images _Image[]
---@field private durations number[]
---@field private loop LoopMode
---@field private events table<integer, string>
---@overload fun(config: ClipConfig): Clip
Clip = class("Clip").extends() or Clip

---@param config ClipConfig
function Clip:init(config)
  Clip.super.init(self)

  -- Validate frames input
  local frames = config.frames
  if frames == nil or #frames <= 0 then
    error("Error - Clip: frames must be a non-empty list", 2)
  end

  -- Validate each individual frame
  self.images = {}
  for i = 1, #frames do
    local frame_index = frames[i]
    local image = config.imagetable:getImage(frame_index)
    if image == nil then
      error(
        "Error - Clip: imagetable has no frame at index "
          .. frame_index
          .. " (clip position "
          .. i
          .. ")",
        2
      )
    end

    self.images[i] = image
  end

  self.durations = normalizeDurations(config.durations, #frames)
  self.loop = config.loop or LOOP_MODE.ONCE

  -- Events keyed by frame position in clip.
  -- e.g. a clip could be indices {5, 2, 3} from a sprite sheet and frame 5 at position 1 could have an event.
  self.events = {}
  for i, name in pairs(config.events or {}) do
    if i < 1 or i > #frames then
      error("Error - Clip: event position " .. i .. " out of range [1, " .. #frames .. "]", 2)
    end
    self.events[i] = name
  end
end

---@return integer
function Clip:frameCount() return #self.images end

--- Get image from clip at position (1 indexed).
---@param position integer
---@return _Image
function Clip:imageAt(position)
  validatePosition(position, #self.images, "imageAt")
  return self.images[position]
end

--- Get duration of frame at position.
---@param position integer
---@return number ms
function Clip:durationAt(position)
  validatePosition(position, #self.durations, "durationAt")
  return self.durations[position]
end

--- Get event name at frame position if it exists.
---@param position integer
---@return string?
function Clip:eventAt(position)
  -- Is position a valid frame?
  validatePosition(position, #self.images, "eventAt")
  -- Potentially nil (not all frames have associated events)
  return self.events[position]
end

---@return LoopMode
function Clip:loopMode() return self.loop end
