import "CoreLibs/object"

import "scripts/Item"
import "scripts/pedestrian/Leg"

local DIRECTION <const> = CONSTANTS.DIRECTION
local PEDESTRIANS <const> = CONSTANTS.PEDESTRIANS
local WORLD <const> = CONSTANTS.WORLD
local ITEM <const> = CONSTANTS.ITEM

-- TODO: maybe do some cool callback function stuff where
-- we get back the uhh active leg htting the ground and know when to switch?
class('Walker').extends()
function Walker:init(walker_type, x, y, vx, vy, direction)
  Walker.super.init(self)

  -- TODO: do we want any leg to accept any item that works?
  self.item_type = walker_type.item
  self.will_drop_item = math.random() <= PEDESTRIANS.ITEM_DROP_CHANCE
  self.has_dropped_item = false
  if (self.will_drop_item) then
    self.drop_at_x = math.random(ITEM.SPAWN_LEFT_BOUND, ITEM.SPAWN_RIGHT_BOUND)
    -- TODO: temp print
    print("Dropping item ", self.item_type, self.drop_at_x)
  end

  self.vx, self.vy = vx, vy
  self.direction = direction

  self.legs = { Leg(x + PEDESTRIANS.LEG_SPACING, y, direction, self.item_type), Leg(x, y, direction, self.item_type) }

  if (direction == DIRECTION.LEFT) then
    self.active_leg_index = 1
  else
    self.active_leg_index = 2
  end

  self.legs[self.active_leg_index]:rise(PEDESTRIANS.STEP_LENGTH, vx, vy)
end

function Walker:update()
  for _, leg in ipairs(self.legs) do
    leg:update()
  end

  -- TODO: maybe function that gets active leg from index? or is that computationally heavy/wasteful?
  local active_leg = self.legs[self.active_leg_index]

   -- TODO: do we want this to be a function?
  if (self.will_drop_item) then
    local x, _ = active_leg:getPosition()
    if (not self.has_dropped_item and
        ((x >= self.drop_at_x and self.direction == DIRECTION.RIGHT) or
        (x <= self.drop_at_x and self.direction == DIRECTION.LEFT)
      )) then
      -- TODO: who do i want to own the item? do i pass it around? or do I want the walker to own it?
      self.item = active_leg:dropItem(self.item_type)
      self.has_dropped_item = true
      -- TODO: temp print
      print("DROPPED ITEM: ", self.item_type, x)
    end
  end

  if (active_leg:justLanded()) then
    self.active_leg_index = (self.active_leg_index % 2) + 1
    active_leg = self.legs[self.active_leg_index]
    active_leg:rise(PEDESTRIANS.STEP_LENGTH, self.vx, self.vy)
  end
end

function Walker:add()
  for _, leg in ipairs(self.legs) do
    leg:add()
  end
end

function Walker:remove()
  for _, leg in ipairs(self.legs) do
    leg:remove()
  end

  -- TODO: HOW TO HANDLE ITEM DELETIONS
end

function Walker:isOffScreen()
  for _, leg in ipairs(self.legs) do
    if (not leg:isOffScreen()) then
      return false
    end
  end

  return true
end

-- TODO: apply same pattern to item and player and leg init/creation
function Walker.spawn(walker_type, direction)
  local x, y, vx, vy

  -- If moving left, spawn on right of screen and move left
  if (direction == DIRECTION.LEFT) then
    x = PEDESTRIANS.SPAWN_POSITION_RIGHT
    vx = PEDESTRIANS.LEFT_VX
  else
    x = PEDESTRIANS.SPAWN_POSITION_LEFT
    vx = PEDESTRIANS.RIGHT_VX
  end

  y = WORLD.FLOOR_Y - PEDESTRIANS.SHOE_H / 2
  vy = PEDESTRIANS.VY

  local walker = Walker(walker_type, x, y, vx, vy, direction)
  walker:add()
  return walker
end
