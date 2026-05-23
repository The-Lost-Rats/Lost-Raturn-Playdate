import "CoreLibs/object"

import "scripts/Item"
import "scripts/pedestrian/Leg"

-- TODO: maybe do some cool callback function stuff where
-- we get back the uhh active leg htting the ground and know when to switch?
class('Walker').extends()
function Walker:init(walker_type, x_pos, y_pos, vx, vy, direction)
  Walker.super.init(self)

  -- TODO: this feeeels a lil off
  if (math.random() <= CONSTANTS.PEDESTRIANS.ITEM_DROP_CHANCE) then
    self.will_drop_item = true
    self.item_type = walker_type.item
    self.has_dropped_item = false
    self.drop_at_x = math.random(CONSTANTS.PEDESTRIANS.ITEM_SPAWN_LEFT_BOUND, CONSTANTS.PEDESTRIANS.ITEM_SPAWN_RIGHT_BOUND)

    -- TODO: temp print
    print("Dropping item ", self.item_type, self.drop_at_x)
  end

  self.vx, self.vy = vx, vy
  self.direction = direction

  self.legs = { Leg(x_pos + CONSTANTS.PEDESTRIANS.LEG_SPACING, y_pos, direction), Leg(x_pos, y_pos, direction) }

  if (direction == CONSTANTS.PEDESTRIANS.DIRECTION.LEFT) then
    self.active_leg_index = 1
  else
    self.active_leg_index = 2
  end

  self.legs[self.active_leg_index]:rise(CONSTANTS.PEDESTRIANS.STEP_LENGTH, vx, vy)
end

function Walker:update()
  for _, leg in ipairs(self.legs) do
    leg:update()
  end

   -- TODO: do we want this to be a function?
  if (self.will_drop_item) then
    x, _ = self.legs[self.active_leg_index]:getPosition()
    if (not self.has_dropped_item and
        ((x >= self.drop_at_x and self.direction == CONSTANTS.PEDESTRIANS.DIRECTION.RIGHT) or
        (x <= self.drop_at_x and self.direction == CONSTANTS.PEDESTRIANS.DIRECTION.LEFT)
      )) then
      -- TODO: who do i want to own the item? do i pass it around? or do I want the walker to own it?
      self.item = Item(self.item_type)
      self.item:add()
      self.legs[self.active_leg_index]:dropItem(self.item)
      self.has_dropped_item = true
      print("DROPPED ITEM: ", self.item_type, x)
    end
  end

  -- TODO: this should be a local :P
  if (self.legs[self.active_leg_index]:justLanded()) then
    self.active_leg_index = (self.active_leg_index % 2) + 1
    self.legs[self.active_leg_index]:rise(CONSTANTS.PEDESTRIANS.STEP_LENGTH, self.vx, self.vy)
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
