import "CoreLibs/object"

import "scripts/pedestrian/Leg"

-- TODO: maybe do some cool callback function stuff where
-- we get back the uhh active leg htting the ground and know when to switch?
class('Walker').extends()
function Walker:init(walker_type, x_pos, y_pos)
  Walker.super.init(self)

  self.walker_type = walker_type
  self.legs = { Leg(x_pos + CONSTANTS.PEDESTRIANS.LEG_SPACING, y_pos), Leg(x_pos, y_pos) }
  self.active_leg_index = 1

  self.legs[self.active_leg_index]:rise(CONSTANTS.PEDESTRIANS.STEP_LENGTH, -5, -5)
end

function Walker:update()
  for _, leg in ipairs(self.legs) do
    leg:update()
  end

  if (self.legs[self.active_leg_index]:justLanded()) then
    self.active_leg_index = (self.active_leg_index % 2) + 1
    self.legs[self.active_leg_index]:rise(CONSTANTS.PEDESTRIANS.STEP_LENGTH, -5, -5)
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
