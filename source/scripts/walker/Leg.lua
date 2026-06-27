-- Leg.lua
-- One leg of a walker. Has two sprites: 1) leg, 2) shoe.
-- Controls leg lifecycle (rise, fall, land).
--

import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

import "scripts/item/Item"

import "scripts/item/itemConstants"
import "scripts/walker/walkerConstants"
import "utilities/constants"

local gfx <const> = playdate.graphics

local DIRECTION <const> = CONSTANTS.DIRECTION
local PHYSICS <const> = CONSTANTS.PHYSICS
local WORLD <const> = CONSTANTS.WORLD

local GROUPS <const> = CONSTANTS.GROUPS
local TAGS <const> = CONSTANTS.TAGS
local LAYERS <const> = CONSTANTS.LAYERS

local ITEM <const> = ITEM_CONSTANTS
local WALKERS <const> = WALKER_CONSTANTS

---@enum MovementState
local MOVEMENT_STATES = {
  FALLING = 0,
  GROUNDED = 1,
  RISING = 2
}

--- Temporary function to build dithered sprite for leg.
---@nodiscard
---@param w integer
---@param h integer
---@param dither_alpha number
---@param dither_type integer
---@return _Image
local function buildDitheredImage(w, h, dither_alpha, dither_type)
  local image = gfx.image.new(w, h)
  assert(image, "Assertion Failed - buildDitheredImage image.new returned nil for " .. w .. "x" .. h)

  gfx.pushContext(image)
    gfx.setDitherPattern(dither_alpha, dither_type)
    gfx.fillRect(0, 0, w, h)
  gfx.popContext()

  return image
end

local LEG_IMAGE <const> = buildDitheredImage(WALKERS.LEG_W, WALKERS.LEG_H, 0.5, gfx.image.kDitherTypeBayer8x8)
local SHOE_IMAGE <const> = buildDitheredImage(WALKERS.SHOE_W, WALKERS.SHOE_H, 0.2, gfx.image.kDitherTypeBayer8x8)

---@class Leg: _Object
---@field item_type ItemType
---@field private direction Direction
---@field private dx_remaining number horizontal distance left for leg to tavel
---@field private x number
---@field private y number
---@field private vx number
---@field private vy number
---@field private just_landed boolean boolean when leg just lands
---@field private current_move_state MovementState
---@field private leg_sprite LegSprite
---@field private shoe_sprite ShoeSprite
---@overload fun(x: number, y: number, direction: Direction, item_type: ItemType): Leg
Leg = class('Leg').extends() or Leg

--#region _____________________________  Init  _____________________________

function Leg:init(x, y, direction, item_type)
  Leg.super.init(self)

  self.item_type = item_type

  self.direction = direction

  self.dx_remaining = 0
  self.x, self.y = 0, 0
  self.vx, self.vy = 0, 0

  self.just_landed = false
  self.current_move_state = MOVEMENT_STATES.GROUNDED

  ---@class LegSprite: _Sprite
  ---@field controller Leg
  ---@field item_type ItemType
  self.leg_sprite = gfx.sprite.new(LEG_IMAGE)
  self.leg_sprite:setZIndex(LAYERS.WALKER)
  -- Set center of sprite to x: center, y: bottom
  self.leg_sprite:setCenter(0.5, 1.0)
  self.leg_sprite:setCollideRect(0, 0, self.leg_sprite:getSize())
  self.leg_sprite:setGroups({GROUPS.CLIMBABLE})
  self.leg_sprite:setTag(TAGS.LEG)
  self.leg_sprite.item_type = item_type
  self.leg_sprite.controller = self

  ---@class ShoeSprite: _Sprite
  ---@field controller Leg
  self.shoe_sprite = gfx.sprite.new(SHOE_IMAGE)
  self.shoe_sprite:setZIndex(LAYERS.WALKER)
  -- Set center of sprite to x: center, y: bottom
  self.shoe_sprite:setCenter(0.5, 1.0)
  self.shoe_sprite:setCollideRect(0, 0, self.shoe_sprite:getSize())
  self.shoe_sprite:setGroups({GROUPS.HAZARD})
  self.shoe_sprite:setTag(TAGS.SHOE)
  self.shoe_sprite.controller = self

  self:moveTo(x, y)
end
--#endregion

--#region _____________________________  Update  _____________________________

function Leg:update()
  if self.current_move_state == MOVEMENT_STATES.RISING then
    self:moveBy(self.vx, self.vy)
    self.dx_remaining = self.dx_remaining - math.abs(self.vx)
    if self.dx_remaining <= 0 then 
      self:fall()
    end
  elseif self.current_move_state == MOVEMENT_STATES.FALLING then
    self.vy = self.vy + PHYSICS.GRAVITY
    self:moveBy(0, self.vy)

    if (self.y >= WORLD.FLOOR_Y) then
      self:land()
    end
  end
end
--#endregion

--#region _____________________________  State Management  _____________________________

---@param step_length number
---@param vx number
---@param vy number
function Leg:rise(step_length, vx, vy)
  self.current_move_state = MOVEMENT_STATES.RISING
  self.vx, self.vy = vx, vy
  self.dx_remaining = step_length
end

---@private
function Leg:fall()
  self.current_move_state = MOVEMENT_STATES.FALLING
  self.vx = 0
end

---@private
function Leg:land()
  self.current_move_state = MOVEMENT_STATES.GROUNDED
  self.y = WORLD.FLOOR_Y
  self.vx, self.vy = 0, 0
  self:moveTo(self.x, self.y)

  self.just_landed = true
end
--#endregion

--#region _____________________________  Sprite Management  _____________________________

function Leg:add()
  self.leg_sprite:add()
  self.shoe_sprite:add()
end

function Leg:remove()
  self.leg_sprite:remove()
  self.shoe_sprite:remove()
end
--#endregion

--#region _____________________________  Movement  _____________________________

---@private
---@param dx number
---@param dy number
function Leg:moveBy(dx, dy)
  self:moveTo(self.x + dx, self.y + dy)
end

---@private
---@param x number
---@param y number
function Leg:moveTo(x, y)
  self.x, self.y = x, y

  local leg_w, _ = self.leg_sprite:getSize()
  local shoe_w, shoe_h = self.shoe_sprite:getSize()

  self.shoe_sprite:moveTo(x, y)
  if (self.direction == DIRECTION.LEFT) then
    self.leg_sprite:moveTo(x + shoe_w / 2 - leg_w / 2, y - shoe_h)
  else
    self.leg_sprite:moveTo(x - shoe_w / 2 + leg_w / 2, y - shoe_h)
  end
end
--#endregion

--#region _____________________________  Queries  _____________________________

-- TODO: maybe also use event system here? fire off a "hey I just landed message?"
--- Check if leg landed since the last call. Sets just landed to false after consumption.
---@nodiscard
---@return boolean
function Leg:justLanded()
  local temp_just_landed = self.just_landed
  self.just_landed = false
  return temp_just_landed
end

---@nodiscard
---@return boolean
function Leg:isOffScreen()
  return self.x < WALKERS.DESPAWN_BOUND_LEFT or self.x > WALKERS.DESPAWN_BOUND_RIGHT
end

---@nodiscard
---@return boolean
function Leg:isRising()
  return self.current_move_state == MOVEMENT_STATES.RISING
end

---@param item_type ItemType
---@return Item
function Leg:dropItem(item_type)
  local item = Item(item_type, self.x, ITEM.SPAWN_Y)
  item:add()
  return item
end

---@nodiscard
---@return number
---@return number
function Leg:getPosition()
  return self.x, self.y
end

---@nodiscard
---@return boolean
function Leg:isFalling()
  return self.current_move_state == MOVEMENT_STATES.FALLING
end

--- Get climbable positions of leg so player movement can clamp to leg.
---@nodiscard
---@return number
---@return number
function Leg:getClimbBounds()
  local _, leg_h = self.leg_sprite:getSize()
  local _, shoe_h = self.shoe_sprite:getSize()

  return self.y - shoe_h - leg_h, self.y - shoe_h
end

--- Get y position above which player is in scoring range.
---@nodiscard
---@return number
function Leg:getScoreThreshold()
  local _, leg_h = self.leg_sprite:getSize()
  local _, shoe_h = self.shoe_sprite:getSize()
  return self.y - shoe_h - leg_h * WALKERS.LEG_SCORE_PERCENT
end

---@nodiscard
---@return integer
function Leg:getDamage()
  return WALKERS.STOMP_DAMAGE
end
--#endregion
