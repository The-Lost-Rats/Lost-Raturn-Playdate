-- Collider.lua
-- Invisible sprite collider for dynamic collision rects.
--

import "CoreLibs/graphics"
import "CoreLibs/object"

import "engine/Signal"

local gfx <const> = playdate.graphics

---@alias ColliderTag integer
---@alias ColliderGroup integer

---@class ColliderConfig
---@field image _Image
---@field groups? ColliderGroup[]
---@field collide_groups? ColliderGroup[]
---@field tag ColliderTag
---@field center [integer, integer] (x, y)
---@field game_object _Object
---@field rect? Rect
---@field flip_mode? integer

---@class Collider: _Object
---@field game_object _Object
---@field flip_mode integer
---@field enter_signal Signal
---@field exit_signal Signal
---@field collider_sprite ColliderSprite
---@overload fun(config: ColliderConfig): Collider
Collider = class("Collider").extends() or Collider

---@param config ColliderConfig
function Collider:init(config)
  self.enter_signal = Signal()
  self.exit_signal = Signal()
  self.game_object = config.game_object

  ---@class ColliderSprite: _Sprite
  ---@field collider Collider
  self.collider_sprite = gfx.sprite.new(config.image)
  self.collider_sprite:setVisible(false)
  self.collider_sprite:setCenter(table.unpack(config.center))

  if config.rect ~= nil then self.collider_sprite:setCollideRect(table.unpack(config.rect)) end

  self:setFlip(config.flip_mode or gfx.kImageUnflipped)

  self.collider_sprite:setGroups(config.groups or {})
  self.collider_sprite:setCollidesWithGroups(config.collide_groups or {})
  self.collider_sprite:setTag(config.tag)

  self.collider_sprite.collider = self
end

--- Set collider rectangle
---@param rect Rect
function Collider:setRect(rect) self.collider_sprite:setCollideRect(table.unpack(rect)) end

--- Clear current collider rectangle
function Collider:clearRect() self.collider_sprite:clearCollideRect() end

--- Move invisible sprite and collider
---@param x integer
---@param y integer
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

  self.collider_sprite:setImageFlip(flip_mode, true)
  self.flip_mode = flip_mode
end

--- Subscribe to on enter collision
---@param listener fun(other: Collider)
---@return integer handle
function Collider:onEnter(listener) return self.enter_signal:subscribe(listener) end

--- Subscribe to on exit collision
---@param listener fun(other: Collider)
---@return integer handle
function Collider:onExit(listener) return self.exit_signal:subscribe(listener) end
