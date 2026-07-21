-- Collider.lua
-- Invisible sprite collider for dynamic collision rects.
--

import "CoreLibs/graphics"
import "CoreLibs/object"

import "engine/Signal"
import "engine/math"

local gfx <const> = playdate.graphics

local next_id = 0

---@alias ColliderTag integer
---@alias ColliderGroup integer

---@class ColliderConfig
---@field image _Image
---@field groups? ColliderGroup[]
---@field collide_groups? ColliderGroup[]
---@field tag ColliderTag
---@field center [number, number] (x, y)
---@field game_object _Object
---@field rect? Rect
---@field flip_mode? integer

---@class Collider: _Object
---@field id integer
---@field enter_signal Signal<Collider>
---@field exit_signal Signal<Collider>
---@field game_object _Object
---@field private flip_mode integer
---@field private collider_sprite ColliderSprite
---@field private rect? Rect Current collider rect. Can be nil for cleared/empty colliders.
---@overload fun(config: ColliderConfig): Collider
Collider = class("Collider").extends() or Collider

---@param config ColliderConfig
function Collider:init(config)
  self.id = next_id
  next_id = next_id + 1

  self.enter_signal = Signal()
  self.exit_signal = Signal()
  self.game_object = config.game_object

  ---@class ColliderSprite: _Sprite
  ---@field collider Collider
  self.collider_sprite = gfx.sprite.new(config.image)
  self.collider_sprite:setVisible(false)

  -- TODO: where should validation live?
  if
    config.center[1] < 0
    or config.center[1] > 1
    or config.center[2] < 0
    or config.center[2] > 1
  then
    error(
      "Error - Collider: collider center values are not in valid range [0, 1.0] - "
        .. config.center[1]
        .. " and "
        .. config.center[2],
      2
    )
  end
  self.collider_sprite:setCenter(table.unpack(config.center))

  self:setFlip(config.flip_mode or gfx.kImageUnflipped)
  if config.rect ~= nil then self:setRect(config.rect) end

  self.collider_sprite:setGroups(config.groups or {})
  self.collider_sprite:setCollidesWithGroups(config.collide_groups or {})
  self.collider_sprite:setTag(config.tag)

  self.collider_sprite.collider = self
end

--- Set collider rectangle
---@param rect Rect Collider rect
function Collider:setRect(rect)
  -- TODO: generalize/share some of these?
  local _, _, w, h = table.unpack(rect)
  if w <= 0 or h <= 0 then
    error(
      "Error - Collider: attempted to create collider with invalid width or height: "
        .. w
        .. ", "
        .. h,
      2
    )
  end

  self.rect = rect
  self:_applyRect()
end

--- Attempt to apply collider rect if it exists onto sprite.
--- Manually mirrors when sprite is flipped.
---@private
function Collider:_applyRect()
  if self.rect == nil then return end

  local x, y, w, h = table.unpack(self.rect)
  if self.flip_mode == gfx.kImageFlippedX then x = self.collider_sprite.width - x - w end
  self.collider_sprite:setCollideRect(x, y, w, h)
end

--- Clear current collider rectangle
function Collider:clearRect()
  self.collider_sprite:clearCollideRect()
  self.rect = nil
end

--- Move invisible sprite and collider
---@param x number
---@param y number
function Collider:moveTo(x, y) self.collider_sprite:moveTo(x, y) end

--- Add sprite to rendering system
function Collider:add() self.collider_sprite:add() end

--- Remove sprite from rendering system
function Collider:remove() self.collider_sprite:remove() end

--- Enable collisions
function Collider:enable() self.collider_sprite:setCollisionsEnabled(true) end

--- Disable collisions
function Collider:disable() self.collider_sprite:setCollisionsEnabled(false) end

--- Set flip direction of sprite and collider
---@param flip_mode integer Flip mode (kImageFlippedX, kImageUnflipped)
function Collider:setFlip(flip_mode)
  if flip_mode ~= gfx.kImageFlippedX and flip_mode ~= gfx.kImageUnflipped then
    error("Error - Collider: invalid flip mode " .. flip_mode, 2)
  end

  self.flip_mode = flip_mode
  self.collider_sprite:setImageFlip(flip_mode, false)
  -- Manually flip collide rect to avoid idempotent responses
  -- e.g. setImageFlip(mode, false), setImageFlip(mode, true) <- won't flip collide rect
  self:_applyRect()
end

--- Flip collider around center Y axis.
function Collider:flipX()
  local new_flip_mode = self.flip_mode == gfx.kImageFlippedX and gfx.kImageUnflipped
    or gfx.kImageFlippedX
  self:setFlip(new_flip_mode)
end

--- Subscribe to on enter collision
---@param listener fun(other: Collider)
---@return integer handle
function Collider:onEnter(listener) return self.enter_signal:subscribe(listener) end

--- Subscribe to on exit collision
---@param listener fun(other: Collider)
---@return integer handle
function Collider:onExit(listener) return self.exit_signal:subscribe(listener) end
