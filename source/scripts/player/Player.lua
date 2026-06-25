import "CoreLibs/animation"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

import "scripts/player/states/ClimbingState"
import "scripts/player/states/DeadState"
import "scripts/player/states/FallingState"
import "scripts/player/states/GroundedState"
import "scripts/player/states/PlayerState"

import "scripts/player/playerConstants"
import "utilities/constants"

local gfx <const> = playdate.graphics

local DIRECTION <const> = CONSTANTS.DIRECTION
local WORLD <const> = CONSTANTS.WORLD
local LAYERS <const> = CONSTANTS.LAYERS
local GROUPS <const> = CONSTANTS.GROUPS
local TAGS <const> = CONSTANTS.TAGS

local PLAYER <const> = PLAYER_CONSTANTS

-- TODO: bigger collision rect for picking up items?
-- TODO: should this be in constants?
local ANIMATION <const> = PLAYER.ANIMATION
local ANIMATION_DEFS <const> = {
  [ANIMATION.IDLE] = { path = "images/player/run", frame_time = 120, hit_box = {25, 20, 32, 22} },
  [ANIMATION.RUN] = { path = "images/player/run", frame_time = 120, hit_box = {25, 20, 32, 22} },
  [ANIMATION.JUMP] = { path = "images/player/run", frame_time = 120, hit_box = {25, 20, 32, 22} },
  [ANIMATION.CLIMB] = { path = "images/player/run", frame_time = 120, hit_box = {25, 20, 32, 22} }
}

local FLIP_DIRECTION <const> = {
  [DIRECTION.LEFT] = gfx.kImageFlippedX,
  [DIRECTION.RIGHT] = gfx.kImageUnflipped
}

local STATES = {
  GROUNDED = GroundedState(),
  FALLING = FallingState(),
  DEAD = DeadState()
  -- Climbing state is created on demand with knowledge of attached leg
}

-- TODO: move from callbacks to event system?
---@class Player: _Sprite
---@field x integer
---@field y integer
---@field initial_health integer
---@field callbacks table
---@overload fun(x: integer, y: integer, initial_health: integer, callbacks: table): Player
Player = class('Player').extends(gfx.sprite) or Player
function Player:init(x, y, initial_health, callbacks)
  Player.super.init(self)

  self.on_deliver = callbacks.on_deliver
  self.on_health_changed = callbacks.on_health_changed

  self.loops, self.hit_boxes = {}, {}
  for name, def in pairs(ANIMATION_DEFS) do
    local image_table = gfx.imagetable.new(def.path)
    assert(image_table, "Assertion Failed - missing image table for animation '" .. name .. "' at " .. def.path)

    -- Set loop to true
    self.loops[name] = gfx.animation.loop.new(def.frame_time, image_table, true)
    self.hit_boxes[name] = def.hit_box
  end

  self:setZIndex(LAYERS.PLAYER)
  -- Set center of sprite to x: center, y: bottom
  self:setCenter(0.5, 1.0)
  self:setGroups({GROUPS.PLAYER})
  self:setCollidesWithGroups({GROUPS.PICK_UP, GROUPS.HAZARD, GROUPS.CLIMBABLE})
  self:setTag(TAGS.PLAYER)

  self.initial_health = initial_health
  self.start_x, self.start_y = x, y
  self:reset()
end

function Player:reset()
  self.health = self.initial_health

  self.vx = 0
  self.vy = 0

  -- TODO: maybe take this as param in class?
  self.current_direction = DIRECTION.RIGHT
  self:setAnimation(ANIMATION.IDLE)
  self:updateAnimationFrame()

  self.held_item = nil
  self.pickup_requested = false

  self:transitionTo(STATES.GROUNDED)
  self:moveTo(self.start_x, self.start_y)
end

function Player:update()
  local state = self.current_state

  if (state:isTerminal()) then return end

  -- Could change state
  self:readInput(state)

  -- Apply forces for state only if it is still active
  if (self.current_state == state) then state:applyForces(self) end

  local x, y = self:getPosition()
  x += self.vx
  y += self.vy

  local hit_edge
  x, hit_edge = self:clampHorizontal(x)

  -- Constrain movement only if state is still active
  if (self.current_state == state) then
    x, y = state:constrain(self, x, y, hit_edge)
  end

  self:moveTo(x, y)

  self:resolveActions(state)

  self:setAnimation(self.current_state:animationName(self))
  self:updateAnimationFrame()
end

function Player:readInput(state)
  local a_pressed = playdate.buttonJustPressed(playdate.kButtonA)
  local b_pressed = playdate.buttonJustPressed(playdate.kButtonB)

  self.pickup_requested = b_pressed
  state:readInput(self, a_pressed, b_pressed)
end

function Player:resolveActions(state)
  if (self.pickup_requested and self.held_item ~= nil) then
    self:dropItem()
    self.pickup_requested = false
  end

  for _, other in ipairs(self:overlappingSprites() or {}) do
    local tag = other:getTag()

    if (self.pickup_requested and tag == TAGS.ITEM) then
      self:pickUp(other)
    else
      state:resolveOverlap(self, other, tag)
    end
  end
end

function Player:transitionTo(next_state)
  if (next_state == self.current_state) then return end
  self.current_state = next_state
  next_state:enter(self)
end

function Player:setAnimation(name)
  if (name == self.current_animation) then return end
  self.current_animation = name
  -- Start new animation from beginning
  self.loops[name].frame = self.loops[name].startFrame
  -- Set current frame to nil so we call setImage
  self.current_frame = nil

  self:setCollideRect(table.unpack(self.hit_boxes[name]))
end

function Player:updateAnimationFrame()
  local loop = self.loops[self.current_animation]
  local frame = loop.frame
  if (frame ~= self.current_frame) then
    self.current_frame = frame
    self:setImage(loop:image(), FLIP_DIRECTION[self.current_direction])
  end
end

function Player:jump()
  self.vy = PLAYER.JUMP_V
  self:transitionTo(STATES.FALLING)
end

function Player:land()
  self.vy = 0
  self:transitionTo(STATES.GROUNDED)
end

function Player:hit(amount)
  self.vy = PLAYER.HIT_KNOCKBACK_V
  self:dropItem()
  self:takeDamage(amount)

  if (not self:isDone()) then self:transitionTo(STATES.FALLING) end
end

function Player:takeDamage(amount)
  self.health = math.max(0, self.health - amount)
  self.on_health_changed(self.health)

  if (self.health == 0) then self:transitionTo(STATES.DEAD) end
end

function Player:grabLeg(leg_sprite)
  self:transitionTo(ClimbingState(leg_sprite.controller))
end

function Player:jumpOffLeg()
  self.vy = PLAYER.DISMOUNT_V
  self:transitionTo(STATES.FALLING)
end

function Player:scoreDelivery(leg)
  if (self.held_item ~= nil) then
    -- TODO: do something cool on correct or incorrect delivery?
    local result = self.on_deliver(self.held_item.item_type, leg.item_type)

    if (result.correct) then
      self.held_item:remove()
      self.held_item = nil
    else
      self:dropItem()
    end
  end

  self:jumpOffLeg()
end

function Player:pickUp(item)
  item:pickUp()
  self.held_item = item
  self.pickup_requested = false
end

function Player:dropItem()
  if (self.held_item ~= nil) then
    self.held_item:release()
    self.held_item = nil
  end
end

function Player:horizontalMovement()
  local vx = 0
  local left_pressed = playdate.buttonIsPressed(playdate.kButtonLeft)
  local right_pressed = playdate.buttonIsPressed(playdate.kButtonRight)

  if (left_pressed) then
    vx -= PLAYER.MOVE_SPEED
    self:setDirection(DIRECTION.LEFT)
  end
  if (right_pressed) then
    vx += PLAYER.MOVE_SPEED
    self:setDirection(DIRECTION.RIGHT)
  end

  return vx
end

function Player:setDirection(direction)
  if (direction == self.current_direction) then return end
  self.current_direction = direction
  -- Set current frame to nil to force redraw with setImage
  self.current_frame = nil
end

function Player:clampHorizontal(x)
  local hit_edge = false

  if (x >= WORLD.W - self.width / 2) then
    x = WORLD.W - self.width / 2
    hit_edge = true
  end

  if (x <= self.width / 2) then
    x = self.width / 2
    hit_edge = true
  end

  return x, hit_edge
end

function Player:usesCrank()
  return self.current_state:usesCrank()
end

function Player:isDone()
  return self.current_state:isTerminal()
end

function Player:getCurrentHealth()
  return self.health
end

function Player:moveTo(x, y)
  Player.super.moveTo(self, x, y)

  if (self.held_item ~= nil) then
    self.held_item:moveTo(x, y - self:getCollideRect().height - PLAYER.HELD_ITEM_Y_GAP)
  end
end
