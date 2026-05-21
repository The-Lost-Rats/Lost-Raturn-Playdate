import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

local gfx <const> = playdate.graphics

-- TODO: constants etc.
local image = gfx.image.new(16, 16, gfx.kColorBlack)

class('Player').extends(gfx.sprite)
function Player:init(vx, vy, direction_x, is_grounded)
  Player.super.init(self)

  self:setImage(image)
  self.vx = vx
  self.vy = vy
  self.direction_x = direction_x
  self.is_grounded = is_grounded
end

function Player:reset()
  self.vx = 0
  self.vy = 0
  self.is_grounded = true

  self:moveTo(CONSTANTS.SCREEN_W_HALF, CONSTANTS.FLOOR_Y - self.height / 2)
end

function Player:update()
  local x, y = self:getPosition()

  -- Handle input
  if (playdate.buttonJustPressed(playdate.kButtonB) and self.is_grounded) then
    self.is_grounded = false

    self.vy += CONSTANTS.PLAYER.JUMP_V
  end

  -- TODO: get x component of forces (gravity, jump, momentum, etc.)
  if (playdate.buttonIsPressed(playdate.kButtonLeft)) then
    x -= CONSTANTS.PLAYER.MOVE_SPEED
  end

  if (playdate.buttonIsPressed(playdate.kButtonRight)) then
    x += CONSTANTS.PLAYER.MOVE_SPEED
  end

  -- Update position
  self.vy = self.vy + CONSTANTS.GRAVITY
  y = y + self.vy
  x = x + self.vx

  -- Bounds check
  if (y >= CONSTANTS.FLOOR_Y - self.height / 2) then
    self.vy = 0
    y = CONSTANTS.FLOOR_Y - self.height / 2
    self.is_grounded = true
  end

  if (x >= CONSTANTS.SCREEN_W - self.width / 2) then
    x = CONSTANTS.SCREEN_W - self.width / 2
  end

  if (x <= self.width / 2) then
    x = self.width / 2
  end

  self:moveTo(x, y)
end
