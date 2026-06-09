import "CoreLibs/object"
import "CoreLibs/sprites"

local gfx <const> = playdate.graphics

class('HUDSprite').extends(gfx.sprite)
function HUDSprite:init(x, y, z_index)
  HUDSprite.super.init(self)

  self:setZIndex(z_index)
  self:setIgnoresDrawOffset(true)
  self:setCenter(0, 0)
  self:moveTo(x, y)
end
