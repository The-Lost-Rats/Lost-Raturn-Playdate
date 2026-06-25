import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

import "scripts/ui/sprites/HUDSprite"

import "scripts/ui/UIConstants"
import "utilities/constants"

local gfx <const> = playdate.graphics

local DISPLAY <const> = CONSTANTS.DISPLAY
local LAYERS <const> = CONSTANTS.LAYERS

local HUD <const> = UI_CONSTANTS.HUD

class('HUDBackgroundSprite').extends(HUDSprite)
function HUDBackgroundSprite:init(x, y)
  HUDBackgroundSprite.super.init(self, x, y, LAYERS.UI_BACKGROUND)

  local image = gfx.image.new(DISPLAY.W, HUD.H, gfx.kColorBlack)
  self:setImage(image)
end
