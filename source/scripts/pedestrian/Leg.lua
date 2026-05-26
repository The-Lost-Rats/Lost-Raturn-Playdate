import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

import "scripts/Item"

local gfx <const> = playdate.graphics

-- TODO: constants/sprites etc.
local leg_image = gfx.image.new(16, 120, gfx.kColorBlack)
local shoe_image = gfx.image.new(32, 20, gfx.kColorBlack)

-- TODO: maybe change to map to functions? and do switch stmt like lookup
local MOVEMENT_STATES = {
  FALLING = 0,
  GROUNDED = 1,
  RISING = 2
}

class('Leg').extends()
function Leg:init(x_pos, y_pos, direction)
  Leg.super.init(self)

  self.direction = direction

  self.dx_remaining = 0
  self.vx, self.vy = 0, 0
  self.x, self.y = 0, 0

  self.just_landed = false

  -- Leg
  self.leg_sprite = gfx.sprite.new(leg_image)
  self.leg_sprite:setCollideRect(0, 0, self.leg_sprite:getSize())
  self.leg_sprite:setGroups({CONSTANTS.GROUPS.CLIMBABLE})
  self.leg_sprite:setTag(CONSTANTS.TAGS.LEG)

  -- Shoe
  self.shoe_sprite = gfx.sprite.new(shoe_image)
  self.shoe_sprite:setCollideRect(0, 0, self.shoe_sprite:getSize())
  self.shoe_sprite:setGroups({CONSTANTS.GROUPS.HAZARD})
  self.shoe_sprite:setTag(CONSTANTS.TAGS.SHOE)

  self:moveTo(x_pos, y_pos)
end

function Leg:update()
  if self.current_move_state == MOVEMENT_STATES.RISING then
    self:moveBy(self.vx, self.vy)
    self.dx_remaining = self.dx_remaining - math.abs(self.vx)
    if self.dx_remaining <= 0 then 
      self:fall()
    end
  elseif self.current_move_state == MOVEMENT_STATES.FALLING then
    self.vy = self.vy + CONSTANTS.GRAVITY
    self:moveBy(0, self.vy)

    -- TODO: shoe height
    if (self.y >= CONSTANTS.FLOOR_Y - 20 / 2) then
      self:land()
    end
  end
end

function Leg:rise(step_length, vx, vy)
  self.current_move_state = MOVEMENT_STATES.RISING
  self.vx, self.vy = vx, vy
  self.dx_remaining = step_length
end

function Leg:fall()
  self.current_move_state = MOVEMENT_STATES.FALLING
  self.vx = 0
  self.vy = self.vy + CONSTANTS.GRAVITY
end

function Leg:land()
  self.current_move_state = MOVEMENT_STATES.GROUNDED
  self.y = CONSTANTS.FLOOR_Y - 20 / 2
  self.vx, self.vy = 0, 0
  self:moveTo(self.x, self.y)

  self.just_landed = true
end

function Leg:add()
  self.leg_sprite:add()
  self.shoe_sprite:add()
end

function Leg:remove()
  self.leg_sprite:remove()
  self.shoe_sprite:remove()
end

function Leg:moveBy(dx, dy)
  self:moveTo(self.x + dx, self.y + dy)
end

-- TODO: this should be private?
function Leg:moveTo(x, y)
  self.x, self.y = x, y

  self.shoe_sprite:moveTo(x, y)
  if (self.direction == CONSTANTS.PEDESTRIANS.DIRECTION.LEFT) then
    self.leg_sprite:moveTo(x + 32 / 2 - 16 / 2, y - 20 /2 - 120 / 2)
  else
    self.leg_sprite:moveTo(x - 32 / 2 + 16 / 2, y - 20 /2 - 120 / 2)
  end
end

function Leg:justLanded()
  local temp_just_landed = self.just_landed
  self.just_landed = false
  return temp_just_landed
end

function Leg:isOffScreen()
  return self.x < CONSTANTS.PEDESTRIANS.DESPAWN_BOUND_LEFT or self.x > CONSTANTS.PEDESTRIANS.DESPAWN_BOUND_RIGHT
end

function Leg:isRising()
  return self.current_move_state == MOVEMENT_STATES.RISING
end

function Leg:dropItem(item)
  item:drop(self.x, -10) -- TODO: -10 should be something..
end

function Leg:getPosition()
  return self.x, self.y
end
