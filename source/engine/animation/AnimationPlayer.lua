-- AnimationPlayer.lua
-- Plays an animation clip. Keeps track of elapsed time, current frame, and advances the clip.
-- Emits signals on frame entry if event exists.
--

import "CoreLibs/object"

import "engine/animation/Clip"
import "engine/math"
import "engine/Signal"

---@class AnimationPlayer: _Object
---@field private event_signal Signal<string> emits an event name when a frame carrying one begins
---@field private clip Clip
---@field private current_frame_index integer current clip position (1 indexed)
---@field private elapsed_time number ms accumulated on the current frame
---@field private is_dirty boolean reports if a frame changed
---@field private direction integer +1 (forward) or -1 (reverse)
---@field private is_complete boolean true once a clip is finished
---@overload fun(clip: Clip): AnimationPlayer
AnimationPlayer = class("AnimationPlayer").extends() or AnimationPlayer

--#region _____________________________  Init/Play  _____________________________

---@param clip Clip
function AnimationPlayer:init(clip)
  AnimationPlayer.super.init(self)
  self.event_signal = Signal()
  self:play(clip)
end

--- Switch to clip and restart from first frame. Used for transitions to new animations.
---@param clip Clip
function AnimationPlayer:play(clip)
  self.clip = clip
  self.current_frame_index = 1
  self.elapsed_time = 0
  self.is_dirty = true
  self.direction = 1
  self.is_complete = false
end
--#endregion

--#region _____________________________  Update  _____________________________

--- Advance animation by dt (ms). Returns true if the frame changed.
---@param dt number
---@return boolean
function AnimationPlayer:update(dt)
  local has_changed = self.is_dirty
  self.is_dirty = false
  if self:isComplete() then return has_changed end

  local old_index = self.current_frame_index
  self.elapsed_time += dt
  while
    not self:isComplete() and self.elapsed_time >= self.clip:durationAt(self.current_frame_index)
  do
    self.elapsed_time -= self.clip:durationAt(self.current_frame_index)
    self:_advance()
  end

  -- Check if there has been a net change after using up dt
  has_changed = has_changed or (old_index ~= self.current_frame_index)
  return has_changed
end
--#endregion

--#region _____________________________  Frame Advance  _____________________________

--- Advance one frame based on loop mode.
--- Emits signal on frame entry if event/tag exists for frame.
---@private
function AnimationPlayer:_advance()
  local old_index = self.current_frame_index
  local loop_mode = self.clip:loopMode()

  if loop_mode == LOOP_MODE.ONCE then
    self:_advanceOneshot()
  elseif loop_mode == LOOP_MODE.LOOP then
    self:_advanceLoop()
  elseif loop_mode == LOOP_MODE.PINGPONG then
    self:_advancePingPong()
  else
    error("Error - attempted to advance animation using undefined loop mode: " .. loop_mode, 2)
  end

  -- Advance actually moved the frame this tick
  if self.current_frame_index ~= old_index then
    local maybe_event_name = self.clip:eventAt(self.current_frame_index)
    if maybe_event_name then self.event_signal:emit(maybe_event_name) end
  end
end

--- Advance frame for one shot loop mode.
--- Sets is complete to true once every frame is played for its full duration.
---@private
function AnimationPlayer:_advanceOneshot()
  local next_frame = self.current_frame_index + 1
  if next_frame > self.clip:frameCount() then
    self.is_complete = true
    next_frame = self.clip:frameCount()
  end

  self.current_frame_index = next_frame
end

--- Advance frame for loop loop mode.
---@private
function AnimationPlayer:_advanceLoop()
  self.current_frame_index = ((self.current_frame_index % self.clip:frameCount()) + 1)
end

--- Advance frame for ping pong loop mode.
---@private
function AnimationPlayer:_advancePingPong()
  local next_frame = self.current_frame_index + self.direction

  if next_frame == 0 then
    self.direction = 1
    next_frame = 2
  elseif next_frame == self.clip:frameCount() + 1 then
    self.direction = -1
    next_frame = self.clip:frameCount() - 1
  end

  --- Clamp incase 2 or frameCount - 1 is outside range (think of a single frame clip)
  next_frame = math.clamp(next_frame, 1, self.clip:frameCount())
  self.current_frame_index = next_frame
end
--#endregion

--#region _____________________________  Queries  _____________________________

--- Frame boxes at current frame.
---@return FrameBoxes
function AnimationPlayer:getFrameBoxes() return self.clip:frameBoxesAt(self.current_frame_index) end

--- Current frame image.
---@return _Image
function AnimationPlayer:getImage() return self.clip:imageAt(self.current_frame_index) end

--- Returns true once a clip has played its last frame.
--- True when a ONCE clip has played fully. Always false for LOOP and PINGPONG.
---@return boolean
function AnimationPlayer:isComplete() return self.is_complete end

---@param listener fun(event_name: string)
---@return integer handle
function AnimationPlayer:onEvent(listener) return self.event_signal:subscribe(listener) end
--#endregion
