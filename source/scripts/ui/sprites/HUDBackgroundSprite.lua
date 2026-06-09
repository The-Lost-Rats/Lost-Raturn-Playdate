import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

import "utilities/constants"

local gfx <const> = playdate.graphics

local DISPLAY <const> = CONSTANTS.DISPLAY
local HUD <const> = CONSTANTS.HUD
local LAYERS <const> = CONSTANTS.LAYERS

class('HUDBackgroundSprite').extends(gfx.sprite)
function HUDBackgroundSprite:init(x, y)
  HUDBackgroundSprite.super.init(self)
  
  self:setZIndex(LAYERS.UI_BACKGROUND)
  self:setIgnoresDrawOffset(true)
  self:setCenter(0, 0)

  local image = gfx.image.new(DISPLAY.W, HUD.H, gfx.kColorBlack)
  self:setImage(image)
  self:moveTo(x, y)
end
