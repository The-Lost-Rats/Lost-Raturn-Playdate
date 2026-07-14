-- Player.lua
-- Handles input, physics, animation and finite state machine for player.
--

import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

import "engine/time"
import "engine/Signal"

import "game/entities/player/PlayerAnimator"
import "game/entities/player/states/ClimbingState"
import "game/entities/player/states/DeadState"
import "game/entities/player/states/FallingState"
import "game/entities/player/states/GroundedState"
import "game/entities/player/states/PlayerState"

import "game/systems/ScoreManager"

import "game/entities/player/playerConstants"
import "game/constants"

local gfx <const> = playdate.graphics

local DIRECTION <const> = CONSTANTS.DIRECTION
local WORLD <const> = CONSTANTS.WORLD
local LAYERS <const> = CONSTANTS.LAYERS
local GROUPS <const> = CONSTANTS.GROUPS
local TAGS <const> = CONSTANTS.TAGS

local PLAYER <const> = PLAYER_CONSTANTS

---@alias HitBox [integer, integer, integer, integer] -- {x, y, w, h}

local FLIP_DIRECTION <const> = {
  [DIRECTION.LEFT] = gfx.kImageFlippedX,
  [DIRECTION.RIGHT] = gfx.kImageUnflipped,
}

local STATES = {
  GROUNDED = GroundedState(),
  FALLING = FallingState(),
  DEAD = DeadState(),
  -- Climbing state is created on demand with knowledge of attached leg
}

---@alias OnDeliver fun(item_type: ItemType, leg_type: ItemType)

---@class Player: _Sprite
---@field on_health_changed Signal<integer> notify new player health
---@field private on_deliver OnDeliver
---@field private initial_health integer
---@field private health integer
---@field private start_x number spawn x, restored on reset
---@field private start_y number spawn y, restored on reset
---@field private vx number
---@field private vy number
---@field private current_direction Direction
---@field private held_item? Item item the player is carrying; can be nil
---@field private pickup_requested boolean
---@field private current_state PlayerState
---@field private animator PlayerAnimator
---@overload fun(x: number, y: number, initial_health: integer, on_deliver: OnDeliver): Player
Player = class("Player").extends(gfx.sprite) or Player

--#region _____________________________  Init/Reset  _____________________________

function Player:init(x, y, initial_health, on_deliver)
  Player.super.init(self)

  self.on_deliver = on_deliver
  self.on_health_changed = Signal()

  self:setZIndex(LAYERS.PLAYER)
  -- Set center of sprite to x: center, y: bottom
  self:setCenter(0.5, 1.0)
  self:setGroups({ GROUPS.PLAYER })
  self:setCollidesWithGroups({ GROUPS.PICK_UP, GROUPS.HAZARD, GROUPS.CLIMBABLE })
  self:setTag(TAGS.PLAYER)

  self.initial_health = initial_health
  self.start_x, self.start_y = x, y

  self.animator = PlayerAnimator()
  self:reset()
end

function Player:reset()
  self.health = self.initial_health

  self.vx = 0
  self.vy = 0

  self.held_item = nil
  self.pickup_requested = false

  -- TODO: maybe take this as param in class?
  self.current_direction = DIRECTION.RIGHT
  self:transitionTo(STATES.GROUNDED)

  self:moveTo(self.start_x, self.start_y)
end
--#endregion

--#region _____________________________  Update  _____________________________

--- Per frame: read input (may switch state), let the active state compute
--- velocity, integrate position, constrain position, resolve collisions,
--- and then advance animation.
function Player:update()
  local state = self.current_state

  if state:isTerminal() then return end

  -- Could change state
  self:readInput(state)

  -- Apply forces for state only if it is still active
  if self.current_state == state then
    self.vx, self.vy = state:applyForces(self, self.vx, self.vy)
  end

  local x, y = self:getPosition()
  x += self.vx
  y += self.vy

  local hit_edge
  x, hit_edge = self:clampHorizontal(x)

  -- Constrain movement only if state is still active
  if self.current_state == state then
    x, y = state:constrain(self, x, y, hit_edge)
  end

  self:moveTo(x, y)

  self:resolveActions(state)

  self.animator:setVy(self.vy)
  self.animator:setGrounded(self:isGrounded())
  self.animator:setMoving(self:isMovingHorizontally())

  if self.animator:update(Time.getDeltaTime()) then
    self:setImage(self.animator:getImage(), FLIP_DIRECTION[self.current_direction])
  end
end
--#endregion

--#region _____________________________  Input Handling  _____________________________

---@private
---@param state PlayerState
function Player:readInput(state)
  local a_pressed = playdate.buttonJustPressed(playdate.kButtonA)
  local b_pressed = playdate.buttonJustPressed(playdate.kButtonB)

  self.pickup_requested = b_pressed
  state:readInput(self, a_pressed, b_pressed)
end

---@private
---@param state PlayerState
function Player:resolveActions(state)
  if self.pickup_requested and self.held_item ~= nil then
    self:dropItem()
    self.pickup_requested = false
  end

  for _, other in ipairs(self:overlappingSprites() or {}) do
    local tag = other:getTag()

    if self.pickup_requested and tag == TAGS.ITEM then
      ---@cast other Item -- Tag guarantees we are an item
      self:pickUp(other)
    else
      state:resolveOverlap(self, other, tag)
    end
  end
end
--#endregion

--#region _____________________________  State Transitions  _____________________________

---@private
---@param next_state PlayerState
function Player:transitionTo(next_state)
  if next_state == self.current_state then return end
  self.current_state = next_state
  next_state:enter(self)
end

function Player:jump()
  self.vy = PLAYER.JUMP_V
  self.animator:jump()
  self:transitionTo(STATES.FALLING)
end

function Player:land()
  self.vy = 0
  self:transitionTo(STATES.GROUNDED)
end

---@param amount integer
function Player:hit(amount)
  self.vy = PLAYER.HIT_KNOCKBACK_V
  self:dropItem()
  self:takeDamage(amount)

  if not self:isDone() then self:transitionTo(STATES.FALLING) end
end

---@private
---@param amount integer
function Player:takeDamage(amount)
  self.health = math.max(0, self.health - amount)
  self.on_health_changed:emit(self.health)

  if self.health == 0 then self:transitionTo(STATES.DEAD) end
end

---@param leg_sprite LegSprite
function Player:grabLeg(leg_sprite)
  self.vx, self.vy = 0, 0
  self:transitionTo(ClimbingState(leg_sprite.controller))
end

function Player:jumpOffLeg()
  self.vy = PLAYER.DISMOUNT_V
  self:transitionTo(STATES.FALLING)
end
--#endregion

--#region _____________________________  Item Handling  _____________________________

---@private
---@param item Item
function Player:pickUp(item)
  item:pickUp()
  self.held_item = item
  self.pickup_requested = false
end

---@private
function Player:dropItem()
  if self.held_item ~= nil then
    self.held_item:release()
    self.held_item = nil
  end
end

---@param leg Leg
function Player:scoreDelivery(leg)
  if self.held_item ~= nil then self.on_deliver(self.held_item.item_type, leg.item_type) end
  self:jumpOffLeg()
end

---@param result ScoreResult
function Player:onDeliveryResult(result)
  if self.held_item == nil then return end

  if result.correct then
    self.held_item:remove()
    self.held_item = nil
  else
    self:dropItem()
  end
end
--#endregion

--#region _____________________________  Movement  _____________________________

--- Returns horizontal velocity based on left right button press.
--- Also sets player direction.
---@nodiscard
---@return number
function Player:horizontalMovement()
  local vx = 0
  local left_pressed = playdate.buttonIsPressed(playdate.kButtonLeft)
  local right_pressed = playdate.buttonIsPressed(playdate.kButtonRight)

  if left_pressed then
    vx -= PLAYER.MOVE_SPEED
    self:setDirection(DIRECTION.LEFT)
  end
  if right_pressed then
    vx += PLAYER.MOVE_SPEED
    self:setDirection(DIRECTION.RIGHT)
  end

  return vx
end

--- Clamps x to keep the player on the screen.
--- Uses sprite size which may not match hit box.
---@private
---@nodiscard
---@param x number
---@return number
---@return boolean
function Player:clampHorizontal(x)
  local hit_edge = false

  if x >= WORLD.W - self.width / 2 then
    x = WORLD.W - self.width / 2
    hit_edge = true
  end

  if x <= self.width / 2 then
    x = self.width / 2
    hit_edge = true
  end

  return x, hit_edge
end

---@param x number
---@param y number
function Player:moveTo(x, y)
  Player.super.moveTo(self, x, y)

  if self.held_item ~= nil then
    self.held_item:moveTo(x, y - self:getCollideRect().height - PLAYER.HELD_ITEM_Y_GAP)
  end
end

---@private
---@param direction Direction
function Player:setDirection(direction)
  if direction == self.current_direction then return end
  self.current_direction = direction
  self:setImageFlip(FLIP_DIRECTION[direction])
end
--#endregion

--#region _____________________________  Getters  _____________________________

---@nodiscard
---@return boolean
function Player:usesCrank() return self.current_state:usesCrank() end

---@nodiscard
---@return boolean
function Player:isDone() return self.current_state:isTerminal() end

---@nodiscard
---@return integer
function Player:getCurrentHealth() return self.health end

---@nodiscard
---@return boolean
function Player:isMovingHorizontally() return self.vx ~= 0 end

---@nodiscard
---@return boolean
function Player:isGrounded() return self.current_state == STATES.GROUNDED end
--#endregion
