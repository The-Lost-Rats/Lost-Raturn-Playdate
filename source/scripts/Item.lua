import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics
local timer <const> = playdate.timer

local ITEM <const> = CONSTANTS.ITEM
local PHYSICS <const> = CONSTANTS.PHYSICS
local WORLD <const> = CONSTANTS.WORLD

local GROUPS <const> = CONSTANTS.GROUPS
local TAGS <const> = CONSTANTS.TAGS
local LAYERS <const> = CONSTANTS.LAYERS

local ITEM_STATES = {
  FALLING = 0,
  GROUNDED = 1,
  DISAPPEARING = 2,
  PICKED_UP = 3
}

class('Item').extends(gfx.sprite)
function Item:init(item_type, x, y)
  Item.super.init(self)

  local item_image_path = item_type.sprite
  local item_image = gfx.image.new(item_image_path)
  assert(item_image, "Assertion Failed - could not load image for item at " .. item_image_path)

  self:setImage(item_image)
  self:setZIndex(LAYERS.ITEM)
  -- Set center of sprite to x: center, y: bottom
  self:setCenter(0.5, 1.0)
  self:setCollideRect(0, 0, self:getSize())
  self:setGroups({GROUPS.PICK_UP})
  self:setTag(TAGS.ITEM)

  self.item_type = item_type
  self.vx, self.vy = 0, 0
  self.is_visible = true

  self:moveTo(x, y)
  self.current_state = ITEM_STATES.FALLING
end

function Item:update()
  if (self.current_state == ITEM_STATES.FALLING) then self:handleFalling()
  elseif(self.current_state == ITEM_STATES.GROUNDED) then self:handleGrounded()
  end
end

function Item:startDisappearing()
  self.current_state = ITEM_STATES.DISAPPEARING
  self.disappear_timer = timer.performAfterDelay(ITEM.TTL_MS, function() self:disappear() end)
  self:startBlinking(ITEM.MAX_BLINK_SPEED_MS)
end

function Item:handleFalling()
  local x, y = self:getPosition()

  self.vy = self.vy + PHYSICS.GRAVITY * ITEM.GRAVITY_MULTIPLIER -- Fall slower than player
  y = y + self.vy
  x = x + self.vx

  if (y >= WORLD.FLOOR_Y) then
    self.vy = 0
    y = WORLD.FLOOR_Y
    self.grounded_start_time_ms = playdate.getCurrentTimeMilliseconds()
    self.current_state = ITEM_STATES.GROUNDED

    self.grounded_timer = timer.performAfterDelay(ITEM.GROUNDED_TIME_MS, function() self:startDisappearing() end)
  end

  self:moveTo(x, y)
end

function Item:handleGrounded()
  local delta_time_s = (playdate.getCurrentTimeMilliseconds() - self.grounded_start_time_ms) / 1000
  local y_offset = ITEM.BOB_AMPLITUDE * math.cos(delta_time_s * math.pi) - ITEM.BOB_AMPLITUDE
  self:moveTo(self.x, WORLD.FLOOR_Y + y_offset)
end

-- TODO: maybe callback chain up to walker and gameplay to notify delete?
function Item:disappear()
  if (self.blinking_timer ~= nil) then
    self.blinking_timer:remove()
  end

  self:remove()
end

function Item:startBlinking(duration_ms)
  local blink_duration_ms = math.max(ITEM.MIN_BLINK_SPEED_MS, duration_ms)

  self.is_visible = not self.is_visible
  self:setVisible(self.is_visible)

  self.blinking_timer = timer.performAfterDelay(blink_duration_ms, function() self:startBlinking(blink_duration_ms / ITEM.BLINK_INTERVAL_DIVISOR) end)
end

function Item:pickUp()
  if (self.grounded_timer ~= nil) then self.grounded_timer:remove() end
  if (self.disappear_timer ~= nil) then self.disappear_timer:remove() end
  if (self.blinking_timer ~= nil) then self.blinking_timer:remove() end

  self.is_visible = true
  self:setVisible(true)
  self.current_state = ITEM_STATES.PICKED_UP
end

function Item:release()
  self.vy = 0
  self.current_state = ITEM_STATES.FALLING
end
