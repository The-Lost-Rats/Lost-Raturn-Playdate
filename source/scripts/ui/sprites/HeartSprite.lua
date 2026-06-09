import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

import "scripts/ui/sprites/HUDSprite"
import "utilities/constants"

local gfx <const> = playdate.graphics

local HUD <const> = CONSTANTS.HUD
local LAYERS <const> = CONSTANTS.LAYERS

local function buildHeartImage(is_filled)
  local diameter <const> = HUD.HEART_DIAMETER
  local height <const> = HUD.H

  local image = gfx.image.new(diameter, height)
  gfx.pushContext(image)
    gfx.setColor(gfx.kColorWhite)
    if (is_filled) then
      gfx.fillCircleInRect(0, 0, diameter, height)
    else
      gfx.drawCircleInRect(0, 0, diameter, height)
    end
  gfx.popContext()
  
  return image
end

local FILLED_IMAGE <const> = buildHeartImage(true)
local EMPTY_IMAGE <const> = buildHeartImage(false)

class('HeartSprite').extends(HUDSprite)
function HeartSprite:init(x, y)
  HeartSprite.super.init(self, x, y, LAYERS.UI)
  self:setFilled(true)
end

function HeartSprite:setFilled(is_filled)
  if (self.is_filled == is_filled) then return end
  self.is_filled = is_filled
  self:setImage(self.is_filled and FILLED_IMAGE or EMPTY_IMAGE)
end
