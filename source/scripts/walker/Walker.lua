-- Walker.lua
-- Controls pedestrian walking across the screen and if they drop an item.
--

import "CoreLibs/object"

import "scripts/item/Item"
import "scripts/walker/Leg"

import "scripts/item/itemConstants"
import "scripts/walker/walkerConstants"
import "utilities/constants"

local DIRECTION <const> = CONSTANTS.DIRECTION
local WORLD <const> = CONSTANTS.WORLD

local WALKERS <const> = WALKER_CONSTANTS
local ITEM <const> = ITEM_CONSTANTS

---@class Walker: _Object
---@field private item_type ItemType
---@field private will_drop_item boolean Random change walker drops item
---@field private has_dropped_item boolean
---@field private drop_at_x? number x value of where to drop item if will_drop_item is true
---@field private vx number
---@field private vy number
---@field private direction Direction
---@field private legs Leg[]
---@field private active_leg_index integer which leg is moving
---@overload fun(walker_type: WalkerType, x: number, y: number, vx: number, vy: number, direction: Direction): Walker
Walker = class("Walker").extends() or Walker

--#region _____________________________  Init  _____________________________

function Walker:init(walker_type, x, y, vx, vy, direction)
  Walker.super.init(self)

  self.item_type = walker_type.item
  self.will_drop_item = math.random() <= WALKERS.ITEM_DROP_CHANCE
  self.has_dropped_item = false
  if self.will_drop_item then
    self.drop_at_x = math.random(ITEM.SPAWN_LEFT_BOUND, ITEM.SPAWN_RIGHT_BOUND)
  end

  self.vx, self.vy = vx, vy
  self.direction = direction

  self.legs = {
    Leg(x + WALKERS.LEG_SPACING, y, direction, self.item_type),
    Leg(x, y, direction, self.item_type),
  }

  if direction == DIRECTION.LEFT then
    self.active_leg_index = 1
  else
    self.active_leg_index = 2
  end

  self.legs[self.active_leg_index]:rise(WALKERS.STEP_LENGTH, vx, vy)
end
--#endregion

--#region _____________________________  Update  _____________________________

--- Alternate moving legs and handle dropping item
function Walker:update()
  for _, leg in ipairs(self.legs) do
    leg:update()
  end

  local active_leg = self.legs[self.active_leg_index]

  if self.will_drop_item then
    local x, _ = active_leg:getPosition()
    if
      not self.has_dropped_item
      and (
        (x >= self.drop_at_x and self.direction == DIRECTION.RIGHT)
        or (x <= self.drop_at_x and self.direction == DIRECTION.LEFT)
      )
    then
      active_leg:dropItem(self.item_type)
      self.has_dropped_item = true
    end
  end

  if active_leg:justLanded() then
    -- Alternate between legs (lists are 1 indexed)
    self.active_leg_index = (self.active_leg_index % #self.legs) + 1
    active_leg = self.legs[self.active_leg_index]
    active_leg:rise(WALKERS.STEP_LENGTH, self.vx, self.vy)
  end
end
--#endregion

--#region _____________________________  Sprite Management  _____________________________

function Walker:add()
  for _, leg in ipairs(self.legs) do
    leg:add()
  end
end

function Walker:remove()
  for _, leg in ipairs(self.legs) do
    leg:remove()
  end
end
--#endregion

--#region _____________________________  Queries  _____________________________

---@nodiscard
---@return boolean
function Walker:isOffScreen()
  for _, leg in ipairs(self.legs) do
    if not leg:isOffScreen() then return false end
  end

  return true
end
--#endregion

--#region _____________________________  Spawning Factory  _____________________________

--- Spawn a walker offscreen
---@nodiscard
---@param walker_type WalkerType
---@param direction Direction
---@return Walker
function Walker.spawn(walker_type, direction)
  local x, y, vx, vy

  -- If moving left, spawn on right of screen and move left
  if direction == DIRECTION.LEFT then
    x = WALKERS.SPAWN_POSITION_RIGHT
    vx = WALKERS.LEFT_VX
  else
    x = WALKERS.SPAWN_POSITION_LEFT
    vx = WALKERS.RIGHT_VX
  end

  y = WORLD.FLOOR_Y
  vy = WALKERS.VY

  local walker = Walker(walker_type, x, y, vx, vy, direction)
  walker:add()
  return walker
end
--#endregion
