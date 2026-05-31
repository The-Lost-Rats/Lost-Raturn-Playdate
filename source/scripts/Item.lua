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

local image = gfx.image.new(ITEM.W, ITEM.H, gfx.kColorBlack)

-- TODO: maybe change to map to functions? and do switch stmt like lookup
local ITEM_STATES = {
  FALLING = 0,
  GROUNDED = 1,
  DISAPPEARING = 2,
  PICKED_UP = 3
}

class('Item').extends(gfx.sprite)
function Item:init(item_type, x, y)
  Item.super.init(self)

  self:setImage(image)
  self:setZIndex(LAYERS.ITEM)
  self:setCollideRect(0, 0, self:getSize())
  self:setGroups({GROUPS.PICK_UP})
  self:setTag(TAGS.ITEM)

  self.item_type = item_type
  self.vx, self.vy = 0, 0
  self.is_visible = true

  self:moveTo(x, y)
  self.current_state = ITEM_STATES.FALLING
end

-- TODO: split into functions
function Item:update()
  local x, y = self:getPosition()

  if (self.current_state == ITEM_STATES.FALLING) then
    -- TODO: see if i can move some of this logic out to be shared
    self.vy = self.vy + PHYSICS.GRAVITY * ITEM.GRAVITY_MULTIPLIER -- Fall slower than player
    y = y + self.vy
    x = x + self.vx

    -- TODO: move to func
    if (y >= WORLD.FLOOR_Y - self.height / 2) then
      self.vy = 0
      y = WORLD.FLOOR_Y - self.height / 2
      self.grounded_start_time_ms = playdate.getCurrentTimeMilliseconds()
      self.current_state = ITEM_STATES.GROUNDED

      self.grounded_timer = timer.performAfterDelay(ITEM.GROUNDED_TIME_MS, function() self:startDisappearing() end)
    end

    self:moveTo(x, y)
  elseif(self.current_state == ITEM_STATES.GROUNDED) then
    -- TODO: bug here where item hits ground and then snaps to center of sine wave (need to phase shift to start at ground)
    local delta_time_s = (playdate.getCurrentTimeMilliseconds() - self.grounded_start_time_ms) / 1000
    local y_offset = ITEM.BOB_AMPLITUDE * math.sin(delta_time_s * math.pi) - ITEM.BOB_AMPLITUDE
    self:moveTo(self.x, WORLD.FLOOR_Y - (self.height / 2) + y_offset)
  end
end

-- TODO: ill keep this as is for now, but I think we should change this to keep the sine motion and add blinking on top
function Item:startDisappearing()
  self.current_state = ITEM_STATES.DISAPPEARING
  self.disappear_timer = timer.performAfterDelay(ITEM.TTL_MS, function() self:disappear() end)
  self:startBlinking(ITEM.MAX_BLINK_SPEED_MS)
end

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

  self:setVisible(true)
  self.current_state = ITEM_STATES.PICKED_UP
end

function Item:release()
  self.current_state = ITEM_STATES.FALLING
end
