-- HUDBackgroundSprite.lua
-- Solid black bar behind the HUD.
--

import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

import "scripts/ui/sprites/HUDSprite"

import "scripts/ui/uiConstants"
import "utilities/constants"

local gfx <const> = playdate.graphics

local DISPLAY <const> = CONSTANTS.DISPLAY
local LAYERS <const> = CONSTANTS.LAYERS

local HUD_CONSTANTS <const> = UI_CONSTANTS.HUD

---@class HUDBackgroundSprite: HUDSprite
---@overload fun(x: integer, y: integer): HUDBackgroundSprite
HUDBackgroundSprite = class("HUDBackgroundSprite").extends(HUDSprite --[[@as table]])
  or HUDBackgroundSprite
function HUDBackgroundSprite:init(x, y)
  HUDBackgroundSprite.super.init(self, x, y, LAYERS.UI_BACKGROUND)

  local image = gfx.image.new(DISPLAY.W, HUD_CONSTANTS.H, gfx.kColorBlack)
  self:setImage(image)
end
