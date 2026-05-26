import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

local gfx <const> = playdate.graphics

-- TODO: constants etc.
local image = gfx.image.new(16, 16, gfx.kColorBlack)

local PLAYER_STATE = {
  GROUNDED = 0,
  JUMPING = 1,
  FALLING = 2,
  CLIMBING = 3
}

class('Player').extends(gfx.sprite)
function Player:init(vx, vy, direction_x)
  Player.super.init(self)

  self:setImage(image)
  self:setCollideRect(0, 0, self:getSize())
  self:setGroups({CONSTANTS.GROUPS.PLAYER})
  self:setCollidesWithGroups({CONSTANTS.GROUPS.PICK_UP, CONSTANTS.GROUPS.HAZARD, CONSTANTS.GROUPS.CLIMBABLE})
  self:setTag(CONSTANTS.TAGS.PLAYER)

  self.vx = vx
  self.vy = vy
  self.direction_x = direction_x
  self.held_item = nil
  self.current_state = PLAYER_STATE.GROUNDED
  self.attached_leg = nil
end

function Player:reset()
  self.vx = 0
  self.vy = 0
  self.current_state = PLAYER_STATE.GROUNDED

  self:moveTo(CONSTANTS.SCREEN_W_HALF, CONSTANTS.FLOOR_Y - self.height / 2)
end

-- TODO: split into functions
function Player:update()
  local x, y = self:getPosition()

  -- TODO: should this go here? do all 3 states share it? Should it go before or after the handles below?
  if (playdate.buttonJustPressed(playdate.kButtonB)) then
    if (self.held_item == nil) then
      local touched_sprites = self:overlappingSprites()
      for _, other_sprite in ipairs(touched_sprites) do
        if (other_sprite:getTag() == CONSTANTS.TAGS.ITEM) then
          self:pickUpItem(other_sprite)
        end
      end
    else
      self.held_item:drop()
      self.held_item = nil
    end
  end

  -- TODO: get x component of forces (gravity, jump, momentum, etc.)
  if (self.current_state == PLAYER_STATE.GROUNDED) then
    x, y = self:handleGrounded(x, y)
  elseif (self.current_state == PLAYER_STATE.JUMPING) then
    x, y = self:handleJumping(x, y)
  elseif (self.current_state == PLAYER_STATE.FALLING) then
    x, y = self:handleFalling(x, y)
  elseif (self.current_state == PLAYER_STATE.CLIMBING) then
    x, y = self:handleClimbing(x, y)
  end

  self:moveTo(x, y)

  if (self.held_item ~= nil) then
    self.held_item:moveTo(x, y - 10)
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

  return x, y
end

function Player:handleJumping(x, y)
  -- TODO: should I really be using a bunch of self variables? seems hard to track over explicit returns...
  self.vy += CONSTANTS.PLAYER.JUMP_V
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
      if (other_sprite:getTag() == CONSTANTS.TAGS.LEG) then
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
  self.vy = self.vy + CONSTANTS.GRAVITY

  x = self:handleHorizontalMovement(x)

  -- Update position
  y = y + self.vy
  x = x + self.vx

   -- Bounds check
  if (y >= CONSTANTS.FLOOR_Y - self.height / 2) then
    self.vy = 0
    y = CONSTANTS.FLOOR_Y - self.height / 2
    self.current_state = PLAYER_STATE.GROUNDED
  end

  return x, y
end

function Player:handleClimbing(x, y)
  -- TODO: handle bounds checking
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

  -- TODO: handle cranking

  -- TODO: I really gotta keep naming consistent and ordering of x and y
  -- Update position
  y = y + self.vy + leg_dy
  x = x + self.vx + leg_dx

  return x, y
end

function Player:handleHorizontalMovement(x_pos)
  if (playdate.buttonIsPressed(playdate.kButtonLeft)) then
    x_pos -= CONSTANTS.PLAYER.MOVE_SPEED
  end

  if (playdate.buttonIsPressed(playdate.kButtonRight)) then
    x_pos += CONSTANTS.PLAYER.MOVE_SPEED
  end

  if (x_pos >= CONSTANTS.SCREEN_W - self.width / 2) then
    x_pos = CONSTANTS.SCREEN_W - self.width / 2
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
