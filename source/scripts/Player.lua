import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

import "utilities/constants"
import "utilities/math"

local gfx <const> = playdate.graphics

local DISPLAY <const> = CONSTANTS.DISPLAY

local CLIMBING <const> = CONSTANTS.CLIMBING
local SCORING <const> = CONSTANTS.SCORING
local PEDESTRIANS <const> = CONSTANTS.PEDESTRIANS
local PHYSICS <const> = CONSTANTS.PHYSICS
local PLAYER <const> = CONSTANTS.PLAYER
local WORLD <const> = CONSTANTS.WORLD
local LAYERS <const> = CONSTANTS.LAYERS

local GROUPS <const> = CONSTANTS.GROUPS
local TAGS <const> = CONSTANTS.TAGS

local image = gfx.image.new(PLAYER.W, PLAYER.H, gfx.kColorBlack)

local PLAYER_STATE = {
  GROUNDED = 0,
  FALLING = 1,
  CLIMBING = 2,
  DEAD = 3
}

class('Player').extends(gfx.sprite)
function Player:init(x, y, initial_health, callbacks)
  Player.super.init(self)

  self.on_score = callbacks.on_score
  self.on_health_changed = callbacks.on_health_changed

  self:setImage(image)
  self:setZIndex(LAYERS.PLAYER)
  -- Set center of sprite to x: center, y: bottom
  self:setCenter(0.5, 1.0)
  self:setCollideRect(0, 0, self:getSize())
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
  self.crank_dy = 0

  self.held_item = nil
  self:dropLeg()

  self.grab_requested = false
  self.pickup_requested = false

  self.current_state = PLAYER_STATE.GROUNDED

  self:moveTo(self.start_x, self.start_y)
end

function Player:update()
  local state = self.current_state

  if (state == PLAYER_STATE.DEAD) then
    self:handleDeath()
    return
  end

  self:readInput(state)

  self:applyForces(state)

  local x, y = self:getPosition()
  x += self.vx
  y += self.vy

  x, y = self:constrain(state, x, y)

  self:moveTo(x, y)

  self:resolveActions(state)
end

function Player:readInput(state)
  local a_pressed = playdate.buttonJustPressed(playdate.kButtonA)
  local b_pressed = playdate.buttonJustPressed(playdate.kButtonB)
  
  if (state == PLAYER_STATE.GROUNDED) then
    if (a_pressed) then self:jump() end
    self.vx = self:horizontalMovement()
  elseif (state == PLAYER_STATE.FALLING) then
    self.vx = self:horizontalMovement()
  elseif (state == PLAYER_STATE.CLIMBING) then
    if (a_pressed) then self:jumpOffLeg() end
    self.crank_dy = self:climb()
  end

  self.grab_requested = (state == PLAYER_STATE.FALLING) and a_pressed
  self.pickup_requested = b_pressed
end

function Player:applyForces(state)
  if (state == PLAYER_STATE.FALLING) then
    self.vy += PHYSICS.GRAVITY
  elseif (state == PLAYER_STATE.CLIMBING and self.attached_leg) then
    local leg_x, leg_y = self.attached_leg:getPosition()

    self.vx = leg_x - self.previous_leg_x
    self.vy = (leg_y - self.previous_leg_y) + self.crank_dy
    self.previous_leg_x, self.previous_leg_y = leg_x, leg_y
  end
end

function Player:constrain(state, x, y)
  local hit_edge
  x, hit_edge = self:clampHorizontal(x)

  if (state == PLAYER_STATE.FALLING) then
    if (y >= WORLD.FLOOR_Y) then
      y = WORLD.FLOOR_Y
      self.vy = 0
      self:setState(PLAYER_STATE.GROUNDED)
    end
  elseif (state == PLAYER_STATE.CLIMBING and self.attached_leg) then
    y = math.clamp(y, self.attached_leg:getClimbBounds())

    if (y <= self.attached_leg:getScoreRange()) then
      self:scoreDelivery()
    elseif (hit_edge) then
      self:jumpOffLeg()
    end
  end

  return x, y
end

function Player:resolveActions(state)
  self:resolveDropItem()
  self:resolveCollisions(state)
end

function Player:resolveDropItem()
  if (self.pickup_requested and self.held_item ~= nil) then
    self:dropItem()
    self.pickup_requested = false
  end
end

function Player:resolveCollisions(state)
  for _, other in ipairs(self:overlappingSprites()) do
    local tag = other:getTag()

    if (self.pickup_requested and tag == TAGS.ITEM) then
      self:pickUp(other)
    elseif (self.grab_requested and tag == TAGS.LEG) then
      self:grabLeg(other)
    elseif (state == PLAYER_STATE.GROUNDED and tag == TAGS.SHOE and other.controller:isFalling()) then
      self:hit()
    end
  end
end

function Player:setState(next_state)
  if (next_state == self.current_state) then return end
  self.current_state = next_state
  self:onEnter(next_state)
end

function Player:onEnter(state)
  if (state == PLAYER_STATE.CLIMBING) then
    self.vx, self.vy = 0, 0
    self.previous_leg_x, self.previous_leg_y = self.attached_leg:getPosition()
  end
end

function Player:jump()
  self.vy = PLAYER.JUMP_V
  self:setState(PLAYER_STATE.FALLING)
end

function Player:hit()
  local next_state

  self.vy = PLAYER.JUMP_V
  self:dropItem()
  self:takeDamage(PEDESTRIANS.STOMP_DAMAGE)

  if (not self:isDead()) then self:setState(PLAYER_STATE.FALLING) end
end

function Player:jumpOffLeg()
  self.vy = PLAYER.JUMP_V
  self:dropLeg()
  self:setState(PLAYER_STATE.FALLING)
end

function Player:dropLeg()
  self.attached_leg = nil
  self.previous_leg_x, self.previous_leg_y = nil, nil
end

function Player:scoreDelivery()
  if (self.held_item ~= nil) then
    local score = self.held_item.item_type == self.attached_leg.item_type and SCORING.CORRECT_DELIVERY or SCORING.WRONG_DELIVERY

    self.on_score(score)
    self.held_item:remove()
    self.held_item = nil
  end

  self:jumpOffLeg()
end

function Player:grabLeg(leg)
  self.attached_leg = leg.controller
  self.grab_requested = false
  self:setState(PLAYER_STATE.CLIMBING)
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

function Player:climb()
  local _, accelerated_change = playdate.getCrankChange()
  local clamped = math.clamp(accelerated_change, -CLIMBING.MAX_ACCELERATED_CHANGE, CLIMBING.MAX_ACCELERATED_CHANGE)

  return -clamped * CLIMBING.PIXELS_PER_DEGREE
end

function Player:handleDeath()
  -- TODO: make badass death animations
  return
end

function Player:horizontalMovement()
  local vx = 0
  local left_pressed = playdate.buttonIsPressed(playdate.kButtonLeft)
  local right_pressed = playdate.buttonIsPressed(playdate.kButtonRight)

  if (left_pressed) then vx -= PLAYER.MOVE_SPEED end
  if (right_pressed) then vx += PLAYER.MOVE_SPEED end

  return vx
end

-- TODO: maybe move to util file?
function Player:clampHorizontal(x)
  local hit_edge = false

  if (x >= DISPLAY.W - self.width / 2) then
    x = DISPLAY.W - self.width / 2
    hit_edge = true
  end

  if (x <= self.width / 2) then
    x = self.width / 2
    hit_edge = true
  end

  return x, hit_edge
end

function Player:takeDamage(amount)
  self.health = math.max(0, self.health - amount)
  self.on_health_changed(self.health)

  if (self.health == 0) then self:setState(PLAYER_STATE.DEAD) end
end

function Player:isDead()
  return self.current_state == PLAYER_STATE.DEAD
end

function Player:isClimbing()
  return self.current_state == PLAYER_STATE.CLIMBING
end

function Player:getCurrentHealth()
  return self.health
end

function Player:moveTo(x, y)
  Player.super.moveTo(self, x, y)

  if (self.held_item ~= nil) then
    self.held_item:moveTo(x, y - self.height - PLAYER.HELD_ITEM_Y_GAP)
  end
end
