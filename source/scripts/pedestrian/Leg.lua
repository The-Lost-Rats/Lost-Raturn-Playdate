import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

import "scripts/Item"

local gfx <const> = playdate.graphics

local DIRECTION <const> = CONSTANTS.DIRECTION
local ITEM <const> = CONSTANTS.ITEM
local PEDESTRIANS <const> = CONSTANTS.PEDESTRIANS
local PHYSICS <const> = CONSTANTS.PHYSICS
local WORLD <const> = CONSTANTS.WORLD

local GROUPS <const> = CONSTANTS.GROUPS
local TAGS <const> = CONSTANTS.TAGS

local leg_image = gfx.image.new(PEDESTRIANS.LEG_W, PEDESTRIANS.LEG_H, gfx.kColorBlack)
local shoe_image = gfx.image.new(PEDESTRIANS.SHOE_W, PEDESTRIANS.SHOE_H, gfx.kColorBlack)

-- TODO: maybe change to map to functions? and do switch stmt like lookup
local MOVEMENT_STATES = {
  FALLING = 0,
  GROUNDED = 1,
  RISING = 2
}

class('Leg').extends()
-- TODO: taking in item type is kinda gross
function Leg:init(x_pos, y_pos, direction, item_type)
  Leg.super.init(self)

  self.item_type = item_type

  self.direction = direction

  self.dx_remaining = 0
  self.vx, self.vy = 0, 0
  self.x, self.y = 0, 0

  self.just_landed = false

  -- Leg
  self.leg_sprite = gfx.sprite.new(leg_image)
  self.leg_sprite:setCollideRect(0, 0, self.leg_sprite:getSize())
  self.leg_sprite:setGroups({GROUPS.CLIMBABLE})
  self.leg_sprite:setTag(TAGS.LEG)
  self.leg_sprite.item_type = item_type
  self.leg_sprite.controller = self

  -- Shoe
  self.shoe_sprite = gfx.sprite.new(shoe_image)
  self.shoe_sprite:setCollideRect(0, 0, self.shoe_sprite:getSize())
  self.shoe_sprite:setGroups({GROUPS.HAZARD})
  self.shoe_sprite:setTag(TAGS.SHOE)
  self.shoe_sprite.controller = self

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
    self.vy = self.vy + PHYSICS.GRAVITY
    self:moveBy(0, self.vy)

    if (self.y >= WORLD.FLOOR_Y - self.shoe_sprite.height / 2) then
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
  self.vy = self.vy + PHYSICS.GRAVITY
end

function Leg:land()
  self.current_move_state = MOVEMENT_STATES.GROUNDED
  self.y = WORLD.FLOOR_Y - self.shoe_sprite.height / 2
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

  local leg_w, leg_h = self.leg_sprite:getSize()
  local shoe_w, shoe_h = self.shoe_sprite:getSize()

  self.shoe_sprite:moveTo(x, y)
  if (self.direction == DIRECTION.LEFT) then
    self.leg_sprite:moveTo(x + shoe_w / 2 - leg_w / 2, y - shoe_h /2 - leg_h / 2)
  else
    self.leg_sprite:moveTo(x - shoe_w / 2 + leg_w / 2, y - shoe_h /2 - leg_h / 2)
  end
end

function Leg:justLanded()
  local temp_just_landed = self.just_landed
  self.just_landed = false
  return temp_just_landed
end

function Leg:isOffScreen()
  return self.x < PEDESTRIANS.DESPAWN_BOUND_LEFT or self.x > PEDESTRIANS.DESPAWN_BOUND_RIGHT
end

function Leg:isRising()
  return self.current_move_state == MOVEMENT_STATES.RISING
end

function Leg:dropItem(item)
  item:drop(self.x, ITEM.SPAWN_Y)
end

function Leg:getPosition()
  return self.x, self.y
end

function Leg:isFalling()
  return self.current_move_state == MOVEMENT_STATES.FALLING
end
