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
  RISING = 2,
}

-- Cache images so instances all share the same loaded image
local image_cache = {}

---@class Leg: _Object
---@field item_type ItemType
---@field private direction Direction
---@field private dx_remaining number horizontal distance left for leg to travel
---@field private x number
---@field private y number
---@field private vx number
---@field private vy number
---@field private just_landed boolean boolean when leg just lands
---@field private current_move_state MovementState
---@field private sprite WalkerSprite
---@field private image_w integer
---@field private image_h integer
---@field private leg_sprite LegSprite
---@field private shoe_sprite ShoeSprite
---@overload fun(x: number, y: number, direction: Direction, item_type: ItemType, sprite: WalkerSprite): Leg
Leg = class("Leg").extends() or Leg

--#region _____________________________  Static Methods  _____________________________

function Leg.loadImage(path)
  local image = image_cache[path]
  if image == nil then
    image =
      assert(gfx.image.new(path), "Assertion Failed - could not load image for walker at " .. path)
    image_cache[path] = image
  end

  return image
end
--#endregion

--#region _____________________________  Init  _____________________________

function Leg:init(x, y, direction, item_type, sprite)
  Leg.super.init(self)

  self.item_type = item_type
  self.direction = direction
  self.sprite = sprite

  self.dx_remaining = 0
  self.x, self.y = 0, 0
  self.vx, self.vy = 0, 0

  self.just_landed = false
  self.current_move_state = MOVEMENT_STATES.GROUNDED

  local image = Leg.loadImage(sprite.path)
  self.image_w, self.image_h = image:getSize()

  -- Flip sprite if leg is moving to the right of the screen (leg sprites point left by default)
  local flip = direction == DIRECTION.RIGHT and gfx.kImageFlippedX or gfx.kImageUnflipped

  ---@class LegSprite: _Sprite
  ---@field controller Leg
  ---@field item_type ItemType
  self.leg_sprite = gfx.sprite.new(image)
  self.leg_sprite:setZIndex(LAYERS.WALKER)
  -- Set center of sprite to x: center, y: bottom
  self.leg_sprite:setCenter(0.5, 1.0)
  self.leg_sprite:setCollideRect(table.unpack(sprite.leg_rect))
  self.leg_sprite:setImageFlip(flip, true)
  self.leg_sprite:setGroups({ GROUPS.CLIMBABLE })
  self.leg_sprite:setTag(TAGS.LEG)
  self.leg_sprite.item_type = item_type
  self.leg_sprite.controller = self

  ---@class ShoeSprite: _Sprite
  ---@field controller Leg
  -- Invisible sprite. Just used for hazard collide rect.
  -- Use the same sprite so we can draw collide rects at known places on sprite.
  self.shoe_sprite = gfx.sprite.new(image)
  self.shoe_sprite:setVisible(false)
  self.shoe_sprite:setZIndex(LAYERS.WALKER)
  -- Set center of sprite to x: center, y: bottom
  self.shoe_sprite:setCenter(0.5, 1.0)
  self.shoe_sprite:setCollideRect(table.unpack(sprite.shoe_rect))
  self.shoe_sprite:setImageFlip(flip, true)
  self.shoe_sprite:setGroups({ GROUPS.HAZARD })
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
    if self.dx_remaining <= 0 then self:fall() end
  elseif self.current_move_state == MOVEMENT_STATES.FALLING then
    self.vy = self.vy + PHYSICS.GRAVITY
    self:moveBy(0, self.vy)

    if self.y >= WORLD.FLOOR_Y then self:land() end
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
function Leg:moveBy(dx, dy) self:moveTo(self.x + dx, self.y + dy) end

--- Move both the leg and shoe sprite/colliders
---@private
---@param x number
---@param y number
function Leg:moveTo(x, y)
  self.x, self.y = x, y
  self.leg_sprite:moveTo(x, y)
  self.shoe_sprite:moveTo(x, y)
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
function Leg:isRising() return self.current_move_state == MOVEMENT_STATES.RISING end

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
function Leg:getPosition() return self.x, self.y end

---@nodiscard
---@return boolean
function Leg:isFalling() return self.current_move_state == MOVEMENT_STATES.FALLING end

---@private
---@nodiscard
---@param local_x number
---@param local_y number
---@return number world_x
---@return number world_y
function Leg:localToWorld(local_x, local_y)
  -- To convert from local to world coords we do the following:
  -- 1. Take the known x or y position (self.x, self.y)
  --      self.x is the center of the sprite; self.y is the bottom of the sprite in world coordinates
  -- 2. Subtract:
  --      For x: half the width to go to the edge of the sprite
  --      For y: the height of the sprite to go to the top
  -- 3. Add the local x or y coordinate to get the world coordinate

  local world_x = self.x - 0.5 * self.image_w + local_x
  local world_y = self.y - self.image_h + local_y

  return world_x, world_y
end

--- Get climbable positions of leg so player movement can clamp to leg.
---@nodiscard
---@return number leg_top
---@return number leg_bottom
function Leg:getClimbBounds()
  local leg_rect = self.sprite.leg_rect
  local local_top = leg_rect[2] -- y: top of sprite
  local local_bottom = leg_rect[2] + leg_rect[4] -- y + height: bottom of sprite

  -- Don't care about x. Just y bounds.
  local _, world_top = self:localToWorld(0, local_top)
  local _, world_bottom = self:localToWorld(0, local_bottom)
  return world_top, world_bottom
end

--- Get y position above which player is in scoring range.
---@nodiscard
---@return number
function Leg:getScoreThreshold()
  local leg_rect = self.sprite.leg_rect
  -- 1 - X% down from the top of the sprite
  local local_y = leg_rect[2] + leg_rect[4] * (1 - WALKERS.LEG_SCORE_PERCENT)
  local _, world_y = self:localToWorld(0, local_y)

  return world_y
end

---@nodiscard
---@return integer
function Leg:getDamage() return WALKERS.STOMP_DAMAGE end
--#endregion
