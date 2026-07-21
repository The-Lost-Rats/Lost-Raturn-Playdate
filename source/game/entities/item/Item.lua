-- Item.lua
-- Manages item lifecycle: drop to ground -> bob up and down -> blink faster and faster
-- till it disappears.
--

import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "engine/assets"
import "engine/collision/Collider"

import "game/entities/item/itemConstants"
import "game/constants"

local gfx <const> = playdate.graphics
local timer <const> = playdate.timer

local ITEM <const> = ITEM_CONSTANTS
local PHYSICS <const> = CONSTANTS.PHYSICS
local WORLD <const> = CONSTANTS.WORLD

local GROUPS <const> = CONSTANTS.GROUPS
local TAGS <const> = CONSTANTS.TAGS
local LAYERS <const> = CONSTANTS.LAYERS

---@enum ItemState
local ITEM_STATES = {
  FALLING = 0,
  GROUNDED = 1,
  DISAPPEARING = 2,
  PICKED_UP = 3,
}

--- List of all items.
--- Used to delete items on game over and clean up state.
local live_items = {}

---@class Item: _Sprite
---@field item_type ItemType
---@field private vx number
---@field private vy number
---@field private is_visible boolean
---@field private current_state ItemState
---@field private disappear_timer? _Timer
---@field private grounded_start_time_ms? number Used for item bob sine wave. Set when item hits the gound.
---@field private grounded_timer? _Timer
---@field private blinking_timer? _Timer
---@field private collider Collider
---@overload fun(item_type: ItemType, x: number, y: number): Item
Item = class("Item").extends(gfx.sprite) or Item

--#region _____________________________  Static Methods  _____________________________

---@return Item[] items List of all active items
function Item.getAll()
  local items = {}
  for item in pairs(live_items) do
    table.insert(items, item)
  end

  return items
end

function Item.preloadImages()
  for _, item_type in pairs(ITEM.TYPES) do
    Assets.loadImage(item_type.sprite, item_type.name)
  end
end
--#endregion

--#region _____________________________  Init  _____________________________

--- Constructor
---@param item_type ItemType
---@param x number
---@param y number
function Item:init(item_type, x, y)
  Item.super.init(self)

  local item_image_path = item_type.sprite
  local item_image = Assets.loadImage(item_image_path, "item " .. item_type.name)
  local sprite_center = { 0.5, 1.0 }

  self:setImage(item_image)
  self:setZIndex(LAYERS.ITEM)
  -- Set center of sprite to x: center, y: bottom
  self:setCenter(table.unpack(sprite_center))

  local collide_rect = { 0, 0, self:getSize() }
  self.collider = Collider({
    image = item_image,
    groups = { GROUPS.PICK_UP },
    tag = TAGS.ITEM,
    center = sprite_center,
    game_object = self,
    rect = collide_rect,
  })

  self.item_type = item_type
  self.vx, self.vy = 0, 0
  self.is_visible = true

  self:moveTo(x, y)
  self.current_state = ITEM_STATES.FALLING
end
--#endregion

--#region _____________________________  Update  _____________________________

function Item:update()
  if self.current_state == ITEM_STATES.FALLING then
    self:handleFalling()
  elseif self.current_state == ITEM_STATES.GROUNDED then
    self:handleGrounded()
  end
end
--#endregion

--#region _____________________________  Falling  _____________________________

--- Falls with dampened gravity. When item hits the floor switch to grounded state
--- and timer to move to disappearing state.
---@private
function Item:handleFalling()
  local x, y = self:getPosition()

  self.vy = self.vy + PHYSICS.GRAVITY * ITEM.GRAVITY_MULTIPLIER -- Fall slower than player
  y = y + self.vy
  x = x + self.vx

  if y >= WORLD.FLOOR_Y then
    self.vy = 0
    y = WORLD.FLOOR_Y
    self.grounded_start_time_ms = playdate.getCurrentTimeMilliseconds()
    self.current_state = ITEM_STATES.GROUNDED

    self.grounded_timer = timer.performAfterDelay(
      ITEM.GROUNDED_TIME_MS,
      function() self:startDisappearing() end
    )
  end

  self:moveTo(x, y)
end
--#endregion

--#region _____________________________  Grounded  _____________________________

---@private
function Item:handleGrounded()
  local delta_time_s = (playdate.getCurrentTimeMilliseconds() - self.grounded_start_time_ms) / 1000
  local y_offset = ITEM.BOB_AMPLITUDE * math.cos(delta_time_s * math.pi) - ITEM.BOB_AMPLITUDE
  self:moveTo(self.x, WORLD.FLOOR_Y + y_offset)
end
--#endregion

--#region _____________________________  Disappearing  _____________________________

--- Start the timer to remove an item and make the item start blinking.
---@private
function Item:startDisappearing()
  self.current_state = ITEM_STATES.DISAPPEARING
  self.disappear_timer = timer.performAfterDelay(ITEM.TTL_MS, function() self:remove() end)
  self:startBlinking(ITEM.MAX_BLINK_SPEED_MS)
end

--- Toggle item visibility at faster and faster rates (floored to MIN_BLINK_SPEED_MS).
---@private
---@param duration_ms number
function Item:startBlinking(duration_ms)
  local blink_duration_ms = math.max(ITEM.MIN_BLINK_SPEED_MS, duration_ms)

  self.is_visible = not self.is_visible
  self:setVisible(self.is_visible)

  self.blinking_timer = timer.performAfterDelay(
    blink_duration_ms,
    function() self:startBlinking(blink_duration_ms / ITEM.BLINK_INTERVAL_DIVISOR) end
  )
end
--#endregion

--#region _____________________________  Pick up and drop  _____________________________

function Item:pickUp()
  self:cancelTimers()

  self.is_visible = true
  self:setVisible(true)
  self.current_state = ITEM_STATES.PICKED_UP
end

function Item:release()
  -- TODO: do we need to zero this out? wouldn't it be more realistic physics wise to just switch states? Do we want drag in x and y also?
  self.vy = 0
  self.current_state = ITEM_STATES.FALLING
end
--#endregion

--#region _____________________________  Object Lifecycle  _____________________________

---@private
function Item:cancelTimers()
  if self.grounded_timer ~= nil then self.grounded_timer:remove() end
  if self.disappear_timer ~= nil then self.disappear_timer:remove() end
  if self.blinking_timer ~= nil then self.blinking_timer:remove() end

  self.grounded_timer = nil
  self.disappear_timer = nil
  self.blinking_timer = nil
end

--- Call super add and then register item in global set.
function Item:add()
  Item.super.add(self)
  self.collider:add()
  live_items[self] = true
end

--- Deregister item from global set by setting to nil (i.e. remove it from set).
--- Then call super remove after we do our own clean up.
function Item:remove()
  live_items[self] = nil
  self:cancelTimers()
  self.collider:remove()
  Item.super.remove(self)
end
--#endregion

--#region _____________________________  Move  _____________________________

--- Move collider in lock step with item
---@param x number
---@param y number
function Item:moveTo(x, y)
  self.collider:moveTo(x, y)
  Item.super.moveTo(self, x, y)
end
--#endregion
