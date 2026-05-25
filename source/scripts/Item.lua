import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics
local timer <const> = playdate.timer

local image = gfx.image.new(8, 8, gfx.kColorBlack)

-- TODO: maybe change to map to functions? and do switch stmt like lookup
local ITEM_STATES = {
  FALLING = 0,
  GROUNDED = 1,
  DISAPPEARING = 2,
  PICKED_UP = 3
}

-- TODO: do we want the item to convert to a mini item when picked up? or do we want a distinct class?
class('Item').extends(gfx.sprite)
-- TODO: item type should really change to like sprite/image or something? or maybe keep and redo look up?
-- TODO: what else should this take in? x, y, vx, vy?
function Item:init(item_type)
  Item.super.init(self)
  self.vx, self.vy = 0, 0
  self:setImage(image)

  -- TODO: should this be passed in as inital state? ITEM STATES would need to be global/in constants
  self.current_state = nil
  self.is_visible = true
end

-- TODO: split into functions
function Item:update()
  local x, y = self:getPosition()

  if (self.current_state == ITEM_STATES.FALLING) then
    -- TODO: see if i can move some of this logic out to be shared
    self.vy = self.vy + CONSTANTS.GRAVITY * 0.60 -- TODO: magic number to fall slower
    y = y + self.vy
    x = x + self.vx

    -- TODO: move to func
    if (y >= CONSTANTS.FLOOR_Y - self.height / 2) then
      self.vy = 0
      y = CONSTANTS.FLOOR_Y - self.height / 2
      self.grounded_start_time_ms = playdate.getCurrentTimeMilliseconds()
      self.current_state = ITEM_STATES.GROUNDED

       -- TODO: item should be its own section
      self.grounded_timer = timer.performAfterDelay(CONSTANTS.PEDESTRIANS.ITEM_GROUNDED_TIME_MS, function() self:startDisappearing() end)
    end

    self:moveTo(x, y)
  elseif(self.current_state == ITEM_STATES.GROUNDED) then
    -- TODO: double check my whiteboard math
    local delta_time_s = (playdate.getCurrentTimeMilliseconds() - self.grounded_start_time_ms) / 1000
    local y_offset = 15 * math.sin(delta_time_s * math.pi) - 15
    self:moveTo(self.x, CONSTANTS.FLOOR_Y - (self.height / 2) + y_offset)
  end
end

function Item:drop(x_pos, y_pos)
  self:moveTo(x_pos, y_pos)
  self.current_state = ITEM_STATES.FALLING
end

-- TODO: ill keep this as is for now, but I think we should change this to keep the sine motion and add blinking on top
function Item:startDisappearing()
  self.current_state = ITEM_STATES.DISAPPEARING
  self.disappear_timer = timer.performAfterDelay(CONSTANTS.PEDESTRIANS.ITEM_TTL_MS, function() self:disappear() end)
  self:startBlinking(CONSTANTS.PEDESTRIANS.ITEM_MAX_BLINK_SPEED_MS)
end

function Item:disappear()
  if (self.blinking_timer ~= nil) then
    self.blinking_timer:remove()
  end

  self:remove()
end

function Item:startBlinking(duration_ms)
  local blink_duration_ms = math.max(CONSTANTS.PEDESTRIANS.ITEM_MIN_BLINK_SPEED_MS, duration_ms)
  
  -- TODO: toggle visibility
  self.is_visible = not self.is_visible
  self:setVisible(self.is_visible)

  -- TODO: make blinking faster as time goes on/or as we get closer to disappaering
  self.blinking_timer = timer.performAfterDelay(blink_duration_ms, function() self:startBlinking(blink_duration_ms / 1.5) end)
end

function Item:pickUp()
  if (self.grounded_timer ~= nil) then self.grounded_timer:remove() end
  if (self.disappear_timer ~= nil) then self.disappear_timer:remove() end
  if (self.blinking_timer ~= nil) then self.blinking_timer:remove() end

  self:setVisible(true)
  self.current_state = ITEM_STATES.PICKED_UP
end
