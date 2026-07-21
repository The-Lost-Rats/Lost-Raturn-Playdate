-- Clip.lua
-- Immutable animation data: an ordered collection of image table frames
-- with per-frame durations, loop modes, and optional frame tagged events.
-- Also contains information on frame boxes.
--

import "CoreLibs/object"

import "engine/math"

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
      "Error - Clip: "
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

--- Validate rectangle has valid dimensions
---@param rect Rect
local function validateRectangle(rect)
  local _, _, w, h = table.unpack(rect)
  if w <= 0 or h <= 0 then
    error(
      "Error - Clip: attempted to create frame box with invalid width or height: " .. w .. ", " .. h,
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

--#region _____________________________  Frame Boxes  _____________________________

---@class FrameBoxConfig
---@field tag string
---@field rect Rect
---@field frames integer[] clip positions (1 indexed)

---@alias FrameBoxes table<string, Rect> -- tag to collide rect for a given frame
--#endregion

--#region _____________________________  Clip  _____________________________

---@class ClipConfig
---@field imagetable _ImageTable source sheet
---@field frames integer[] imagetable cell indices in play order (1 indexed)
---@field durations number | number[] one value for all frames or a value per frame (in ms)
---@field loop? LoopMode defaults to ONCE
---@field events? table<integer, string> clip position (1 indexed) to event name
---@field frame_boxes? FrameBoxConfig[] Frame box per frame (can have multiple per frame)

---@class Clip: _Object
---@field private images _Image[]
---@field private durations number[]
---@field private loop LoopMode
---@field private events table<integer, string>
---@field private frame_boxes table<integer, FrameBoxes>
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

  -- Validate each individual frame and initialise frame boxes to empty
  self.images = {}
  self.frame_boxes = {}
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
    self.frame_boxes[i] = {}
  end

  self.durations = normalizeDurations(config.durations, #frames)
  self.loop = config.loop or LOOP_MODE.ONCE

  -- Events keyed by frame position in clip.
  -- e.g. a clip could be indices {5, 2, 3} from a sprite sheet and frame 5 at position 1 could have an event.
  self.events = {}
  for i, name in pairs(config.events or {}) do
    validatePosition(i, #frames, "init:events")
    self.events[i] = name
  end

  -- Validate and populate frame boxes
  for _, box_config in ipairs(config.frame_boxes or {}) do
    validateRectangle(box_config.rect)

    for _, frame in ipairs(box_config.frames) do
      validatePosition(frame, #frames, "init:frame_boxes")
      if self.frame_boxes[frame][box_config.tag] then
        error(
          "Error - Clip: multiple frame boxes tagged " .. box_config.tag .. " on frame " .. frame,
          2
        )
      end
      self.frame_boxes[frame][box_config.tag] = box_config.rect
    end
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

--- Return frame boxes at frame position. Can be multiple.
---@param position integer
---@return FrameBoxes
function Clip:frameBoxesAt(position)
  validatePosition(position, #self.images, "frameBoxesAt")
  return self.frame_boxes[position]
end

---@return LoopMode
function Clip:loopMode() return self.loop end

--- Get all tags for this clip's frame boxes.
---@return table<string, true>
function Clip:boxTags()
  local tags = {}
  for _, frame_box in pairs(self.frame_boxes) do
    for tag in pairs(frame_box) do
      tags[tag] = true
    end
  end

  return tags
end
--#endregion
