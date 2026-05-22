import "CoreLibs/object"

import "scripts/pedestrian/Leg"

-- TODO: maybe do some cool callback function stuff where
-- we get back the uhh active leg htting the ground and know when to switch?
class('Walker').extends()
function Walker:init(walker_type, x_pos, y_pos, vx, vy, direction)
  Walker.super.init(self)

  self.vx, self.vy = vx, vy

  self.walker_type = walker_type
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
end

function Walker:isOffScreen()
  for _, leg in ipairs(self.legs) do
    if (not leg:isOffScreen()) then
      return false
    end
  end

  return true
end
