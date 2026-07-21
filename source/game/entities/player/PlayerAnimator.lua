-- PlayerAnimator.lua
-- Finite state machine for player animation.
--

import "CoreLibs/object"

import "engine/assets"
import "engine/animation/Clip"
import "engine/animation/Parameters"
import "engine/animation/AnimationController"
import "engine/collision/AnimatedColliderSet"
import "engine/collision/Collider"

import "game/constants"
import "game/entities/player/playerConstants"

local PLAYER <const> = PLAYER_CONSTANTS

local GROUPS <const> = CONSTANTS.GROUPS
local TAGS <const> = CONSTANTS.TAGS

local JUMP_FRAMES <const> = {
  CROUCH = 1,
  RISE = 2,
  HANG = 3,
  FALL = 4,
  LAND_SQUISH = 5,
  LAND_POP_UP = 6,
}
local APEX_VY <const> = 2

---@class PlayerAnimator: _Object
---@field private controller AnimationController
---@field private collider_set AnimatedColliderSet
---@overload fun(player: Player): PlayerAnimator
PlayerAnimator = class("PlayerAnimator").extends() or PlayerAnimator

--- Create animation and collider controllers.
---@param player _Object
function PlayerAnimator:init(player)
  PlayerAnimator.super.init(self)

  -- Clips --------------------------------------------------------------
  local idle_sheet = Assets.loadImageTable "images/player/idle"
  local run_sheet = Assets.loadImageTable "images/player/run"
  local jump_sheet = Assets.loadImageTable "images/player/jump"

  local idle_clip = Clip({
    imagetable = idle_sheet,
    frames = { 1, 2 },
    durations = 120,
    loop = LOOP_MODE.LOOP,
    frame_boxes = {
      { tag = "hitbox", rect = { 30, 12, 33, 18 }, frames = { 1, 2 } },
      { tag = "grabbox", rect = { 30, 12, 66, 36 }, frames = { 1, 2 } },
    },
  })
  local run_clip = Clip({
    imagetable = run_sheet,
    frames = { 1, 2, 3, 4 },
    durations = 120,
    loop = LOOP_MODE.LOOP,
    frame_boxes = {
      { tag = "hitbox", rect = { 25, 20, 32, 22 }, frames = { 1, 2, 3, 4 } },
      { tag = "grabbox", rect = { 25, 20, 64, 44 }, frames = { 1, 2, 3, 4 } },
    },
  })
  local rise_clip = Clip({
    imagetable = jump_sheet,
    frames = { JUMP_FRAMES.RISE },
    durations = 100,
    loop = LOOP_MODE.LOOP,
    frame_boxes = {
      { tag = "hitbox", rect = { 25, 20, 32, 22 }, frames = { 1 } },
      { tag = "grabbox", rect = { 25, 20, 64, 44 }, frames = { 1 } },
    },
  })
  local hang_clip = Clip({
    imagetable = jump_sheet,
    frames = { JUMP_FRAMES.HANG },
    durations = 100,
    loop = LOOP_MODE.LOOP,
    frame_boxes = {
      { tag = "hitbox", rect = { 25, 20, 32, 22 }, frames = { 1 } },
      { tag = "grabbox", rect = { 25, 20, 64, 44 }, frames = { 1 } },
    },
  })
  local fall_clip = Clip({
    imagetable = jump_sheet,
    frames = { JUMP_FRAMES.FALL },
    durations = 100,
    loop = LOOP_MODE.LOOP,
    frame_boxes = {
      { tag = "hitbox", rect = { 25, 20, 32, 22 }, frames = { 1 } },
      { tag = "grabbox", rect = { 25, 20, 64, 44 }, frames = { 1 } },
    },
  })
  local land_clip = Clip({
    imagetable = jump_sheet,
    frames = { JUMP_FRAMES.LAND_SQUISH, JUMP_FRAMES.LAND_POP_UP },
    durations = { 120, 80 },
    loop = LOOP_MODE.ONCE,
    frame_boxes = {
      { tag = "hitbox", rect = { 25, 20, 32, 22 }, frames = { 1, 2 } },
      { tag = "grabbox", rect = { 25, 20, 64, 44 }, frames = { 1, 2 } },
    },
  })

  -- States --------------------------------------------------------------
  local idle = AnimationState(idle_clip)
  local run = AnimationState(run_clip)
  local rise = AnimationState(rise_clip)
  local hang = AnimationState(hang_clip)
  local fall = AnimationState(fall_clip)
  local land = AnimationState(land_clip)

  -- Transitions --------------------------------------------------------------
  idle.transitions = {
    Transition(rise):addCondition("jump", TRANSITION_OP.EQUAL_TO, true),
    Transition(run):addCondition("moving", TRANSITION_OP.EQUAL_TO, true),
  }
  run.transitions = {
    Transition(rise):addCondition("jump", TRANSITION_OP.EQUAL_TO, true),
    Transition(idle):addCondition("moving", TRANSITION_OP.EQUAL_TO, false),
  }
  rise.transitions = {
    Transition(hang):addCondition("vy", TRANSITION_OP.GREATER_THAN, -APEX_VY),
  }
  hang.transitions = {
    Transition(fall):addCondition("vy", TRANSITION_OP.GREATER_THAN, APEX_VY),
  }
  fall.transitions = {
    Transition(land):addCondition("grounded", TRANSITION_OP.EQUAL_TO, true),
  }
  land.transitions = {
    Transition(run, true):addCondition("moving", TRANSITION_OP.EQUAL_TO, true),
    Transition(idle, true),
  }

  -- Parameters --------------------------------------------------------------
  local params = Parameters()
  params:declareNumber("vy", 0)
  params:declareBoolean("grounded", true)
  params:declareBoolean("moving", false)
  params:declareTrigger "jump"

  self.controller = AnimationController(idle, params, {})

  -- Colliders --------------------------------------------------------------
  self.collider_set = AnimatedColliderSet({
    size = { PLAYER.COLLISION_W, PLAYER.COLLISION_H },
    game_object = player,
    tag_map = {
      hitbox = {
        groups = { GROUPS.PLAYER },
        collide_groups = { GROUPS.HAZARD },
        tag = TAGS.PLAYER,
        center = { 0.5, 1.0 },
      },
      grabbox = {
        groups = { GROUPS.PLAYER },
        collide_groups = { GROUPS.PICK_UP, GROUPS.CLIMBABLE },
        tag = TAGS.PLAYER,
        center = { 0.5, 1.0 },
      },
    },
  })

  -- Verify colliders exist for every tag defined
  for _, clip in ipairs({ idle_clip, run_clip, rise_clip, hang_clip, fall_clip, land_clip }) do
    for tag in pairs(clip:boxTags()) do
      self.collider_set:getCollider(tag)
    end
  end
end

---@param vy number
function PlayerAnimator:setVy(vy) self.controller:setNumber("vy", vy) end

---@param grounded boolean
function PlayerAnimator:setGrounded(grounded) self.controller:setBoolean("grounded", grounded) end

---@param moving boolean
function PlayerAnimator:setMoving(moving) self.controller:setBoolean("moving", moving) end

function PlayerAnimator:jump() self.controller:setTrigger "jump" end

--- Advance the animation. Return true if the frame changed.
---@param dt number (ms)
---@param x number
---@param y number
---@param flip integer
---@return boolean
function PlayerAnimator:update(dt, x, y, flip)
  local changed = self.controller:update(dt)
  if changed then self.collider_set:applyBoxes(self.controller:getFrameBoxes()) end
  self.collider_set:follow(x, y, flip)
  return changed
end

---@return _Image
function PlayerAnimator:getImage() return self.controller:getImage() end

---@param listener fun(event_name: string)
---@return integer handle
function PlayerAnimator:onEvent(listener) return self.controller:onEvent(listener) end

--- Return overlapping sprites for collider with given tag
---@param tag string
---@return ColliderSprite[]
function PlayerAnimator:getOverlaps(tag) return self.collider_set:getCollider(tag):getOverlaps() end

function PlayerAnimator:add() self.collider_set:add() end

function PlayerAnimator:remove() self.collider_set:remove() end
