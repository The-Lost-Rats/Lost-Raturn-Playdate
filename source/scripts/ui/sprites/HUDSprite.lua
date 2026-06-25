import "CoreLibs/object"
import "CoreLibs/sprites"

local gfx <const> = playdate.graphics

---@class HUDSprite: _Sprite
---@field x: integer
---@field y: integer
---@field z_index: integer
---@overload fun(x: integer, y: integer, z_index: integer): HUDSprite
HUDSprite = class('HUDSprite').extends(gfx.sprite) or HUDSprite
function HUDSprite:init(x, y, z_index)
  HUDSprite.super.init(self)

  self:setZIndex(z_index)
  self:setIgnoresDrawOffset(true)
  self:setCenter(0, 0)
  self:moveTo(x, y)
end
