import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

import "utilities/math"

local gfx <const> = playdate.graphics

local DISPLAY <const> = CONSTANTS.DISPLAY
local HUD <const> = CONSTANTS.HUD

-- TODO: does player need all this data?
local CLIMBING <const> = CONSTANTS.CLIMBING
local SCORING <const> = CONSTANTS.SCORING
local PEDESTRIANS <const> = CONSTANTS.PEDESTRIANS
local PHYSICS <const> = CONSTANTS.PHYSICS
local PLAYER <const> = CONSTANTS.PLAYER
local WORLD <const> = CONSTANTS.WORLD

local GROUPS <const> = CONSTANTS.GROUPS
local TAGS <const> = CONSTANTS.TAGS

local image = gfx.image.new(PLAYER.W, PLAYER.H, gfx.kColorBlack)

-- TODO: remove some of these states and make them state transitions
local PLAYER_STATE = {
  GROUNDED = 0,
  JUMPING = 1,
  FALLING = 2,
  CLIMBING = 3,
  SCORING = 4,
  HIT = 5,
  DEAD = 6
}

class('Player').extends(gfx.sprite)
function Player:init(vx, vy, direction_x, initial_health, game_play_scene)
  Player.super.init(self)

  self.game_play_scene = game_play_scene

  self:setImage(image)
  self:setCollideRect(0, 0, self:getSize())
  self:setGroups({GROUPS.PLAYER})
  self:setCollidesWithGroups({GROUPS.PICK_UP, GROUPS.HAZARD, GROUPS.CLIMBABLE})
  self:setTag(TAGS.PLAYER)

  self.health = initial_health

  self.vx = vx
  self.vy = vy
  self.initial_direction_x = direction_x
  self.direction_x = self.initial_direction_x

  self.held_item = nil
  self.attached_leg = nil

  self.current_state = PLAYER_STATE.GROUNDED
end

function Player:reset()
  self.health = PLAYER.MAX_HEALTH

  self.vx = 0
  self.vy = 0
  self.direction_x = self.initial_direction_x
  
  self.held_item = nil
  self.attached_leg = nil

  self.current_state = PLAYER_STATE.GROUNDED

  -- TODO: should i pass in x and y?
  self:moveTo(DISPLAY.W_HALF, WORLD.FLOOR_Y - self.height / 2)
end

-- TODO: split into functions
function Player:update()
  local x, y = self:getPosition()

  if (self.health == 0) then
    self.current_state = PLAYER_STATE.DEAD
  end

  -- TODO: should this go here? do all 3 states share it? Should it go before or after the handles below?
  if (playdate.buttonJustPressed(playdate.kButtonB)) then
    if (self.held_item == nil) then
      local touched_sprites = self:overlappingSprites()
      for _, other_sprite in ipairs(touched_sprites) do
        if (other_sprite:getTag() == TAGS.ITEM) then
          self:pickUpItem(other_sprite)
        end
      end
    else
      self.held_item:release()
      self.held_item = nil
    end
  end

  -- TODO: get x component of forces (gravity, jump, momentum, etc.)
  -- TODO: switch statement table thing?
  -- TODO: all these taking in position kinda sux?
  if (self.current_state == PLAYER_STATE.GROUNDED) then
    x, y = self:handleGrounded(x, y)
  elseif (self.current_state == PLAYER_STATE.JUMPING) then
    x, y = self:handleJumping(x, y)
  elseif (self.current_state == PLAYER_STATE.FALLING) then
    x, y = self:handleFalling(x, y)
  elseif (self.current_state == PLAYER_STATE.CLIMBING) then
    x, y = self:handleClimbing(x, y)
  elseif (self.current_state == PLAYER_STATE.SCORING) then
    x, y = self:handleScoring(x, y)
  elseif (self.current_state == PLAYER_STATE.HIT) then
    x, y = self:handleHit(x, y)
  elseif (self.current_state == PLAYER_STATE.DEAD) then
    x, y = self:handleDeath(x, y)
  end

  self:moveTo(x, y)

  if (self.held_item ~= nil) then
    self.held_item:moveTo(x, y + PLAYER.HELD_ITEM_Y_OFFSET)
  end
end

function Player:handleGrounded(x, y)
  -- Handle input
  if (playdate.buttonJustPressed(playdate.kButtonA)) then
    self.current_state = PLAYER_STATE.JUMPING
    -- TODO: should this return? will it cause a break in player input?
  end

  -- TODO: these lines seem to be common in all except crank?
  x = self:handleHorizontalMovement(x)

  -- Update position
  y = y + self.vy
  x = x + self.vx

  -- TODO: should this be before or after move?
  local touched_sprites = self:overlappingSprites()
  for _, other_sprite in ipairs(touched_sprites) do
    if (other_sprite:getTag() == TAGS.SHOE and other_sprite.controller:isFalling()) then
      self.current_state = PLAYER_STATE.HIT
    end
  end

  return x, y
end

function Player:handleJumping(x, y)
  -- TODO: should I really be using a bunch of self variables? seems hard to track over explicit returns...
  self.vy += PLAYER.JUMP_V
  self.current_state = PLAYER_STATE.FALLING

  x = self:handleHorizontalMovement(x)

  -- Update position
  y = y + self.vy
  x = x + self.vx

  -- TODO: should i handle touching leg here? as well as in falling?

  return x, y
end

function Player:handleFalling(x, y)
  if (playdate.buttonJustPressed(playdate.kButtonA)) then
    local touched_sprites = self:overlappingSprites()
    for _, other_sprite in ipairs(touched_sprites) do
      if (other_sprite:getTag() == TAGS.LEG) then
        self.attached_leg = other_sprite
        self.current_state = PLAYER_STATE.CLIMBING
        self.vx, self.vy = 0, 0
        self.previous_leg_x, self.previous_leg_y = other_sprite:getPosition()
      end
    end

    -- TODO: should I return out of this since I don't want the player to keep falling?
    return x, y
  end

  -- Update position
  self.vy = self.vy + PHYSICS.GRAVITY

  x = self:handleHorizontalMovement(x)

  -- Update position
  y = y + self.vy
  x = x + self.vx

   -- Bounds check
  if (y >= WORLD.FLOOR_Y - self.height / 2) then
    self.vy = 0
    y = WORLD.FLOOR_Y - self.height / 2
    self.current_state = PLAYER_STATE.GROUNDED
  end

  return x, y
end

function Player:handleClimbing(x, y)
  if (playdate.buttonJustPressed(playdate.kButtonA)) then
    self.current_state = PLAYER_STATE.JUMPING
    self.attached_leg = nil
    self.previous_leg_x, self.previous_leg_y = nil, nil
    return x, y
  end

  -- TODO: should I nil check?
  -- TODO: delta works in our case cuz the leg is simple and straight - but what if it is more complex? we will need to know how the attach/current leg point moves. How do i get the attach point? Do I need to track it or can collisions get us this?
  local leg_x, leg_y = self.attached_leg:getPosition()
  local leg_dx = leg_x - self.previous_leg_x
  local leg_dy = leg_y - self.previous_leg_y

  self.previous_leg_x = leg_x
  self.previous_leg_y = leg_y

  -- Handle crank motion
  -- TODO: should we use change or accelerated change?
  local _, acceleratedChange = playdate.getCrankChange()
  local clamped_change = math.clamp(acceleratedChange, -CLIMBING.MAX_ACCELERATED_CHANGE, CLIMBING.MAX_ACCELERATED_CHANGE)
  local dy = -clamped_change * CLIMBING.PIXELS_PER_DEGREE


  -- TODO: I really gotta keep naming consistent and ordering of x and y
  -- Update position
  y = y + self.vy + leg_dy + dy
  x = x + self.vx + leg_dx

  -- TODO: handle this better w/ image anchors and get height of leg
  if (y < leg_y - PEDESTRIANS.LEG_H / 2 - self.height / 2) then
    y = leg_y - PEDESTRIANS.LEG_H / 2 - self.height / 2
  elseif (y > leg_y + PEDESTRIANS.LEG_H / 2 - self.height / 2) then
    y = leg_y + PEDESTRIANS.LEG_H / 2 - self.height / 2
  end

    -- TODO: off screen should be helper? also make drop leg a helper?
    -- TODO: is this unsafe? should I check if the leg exists before using it above?
  if (x >= DISPLAY.W - self.width / 2) then
    x = DISPLAY.W - self.width / 2
    self.current_state = PLAYER_STATE.JUMPING
    self.attached_leg = nil
    self.previous_leg_x, self.previous_leg_y = nil, nil
  end

  if (x <= self.width / 2) then
    x = self.width / 2
    self.current_state = PLAYER_STATE.JUMPING
    self.attached_leg = nil
    self.previous_leg_x, self.previous_leg_y = nil, nil
  end

  if (y <= leg_y - CLIMBING.LEG_SCORE_DISTANCE) then
    self.current_state = PLAYER_STATE.SCORING
  end

  return x, y
end

function Player:handleScoring(x, y)
  if (self.held_item ~= nil) then
    -- TODO: clean this up
    if (self.held_item.item_type == self.attached_leg.item_type) then
      print("Score! ", self.held_item.item_type, self.attached_leg.item_type)
      self.game_play_scene:updateScore(SCORING.CORRECT_DELIVERY)

      self.held_item:remove()
      self.held_item = nil
    else
      print("Miss! ", self.held_item.item_type, self.attached_leg.item_type)
      self.game_play_scene:updateScore(SCORING.WRONG_DELIVERY)
      self.held_item:release()
      self.held_item = nil
    end
  end

  self.current_state = PLAYER_STATE.JUMPING
  self.attached_leg = nil
  self.previous_leg_x, self.previous_leg_y = nil, nil
  return x, y
end

function Player:handleHit(x, y)
  self.vy += PLAYER.JUMP_V
  self.current_state = PLAYER_STATE.FALLING

  if (self.held_item ~= nil) then
    self.held_item:release()
    self.held_item = nil
  end

  self:takeDamage(PEDESTRIANS.STOMP_DAMAGE)

  return x, y
end

function Player:handleDeath(x, y)
  -- TODO: do cool stuff on death?
  return x, y
end

function Player:handleHorizontalMovement(x_pos)
  if (playdate.buttonIsPressed(playdate.kButtonLeft)) then
    x_pos -= PLAYER.MOVE_SPEED
  end

  if (playdate.buttonIsPressed(playdate.kButtonRight)) then
    x_pos += PLAYER.MOVE_SPEED
  end

  if (x_pos >= DISPLAY.W - self.width / 2) then
    x_pos = DISPLAY.W - self.width / 2
  end

  if (x_pos <= self.width / 2) then
    x_pos = self.width / 2
  end

  return x_pos
end

function Player:pickUpItem(item)
  item:pickUp()
  self.held_item = item
end

function Player:isClimbing()
  return self.current_state == PLAYER_STATE.CLIMBING
end

function Player:getCurrentHealth()
  return self.health
end

-- TODO: gfx update should not be here - should be in ui or smth?
function Player:takeDamage(amount)
  self.health = math.max(0, self.health - amount)
  gfx.sprite.addDirtyRect(0, 0, DISPLAY.W, HUD.H)
end

function Player:isDead()
  return self.current_state == PLAYER_STATE.DEAD
end
