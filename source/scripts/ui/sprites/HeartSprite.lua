import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

import "scripts/ui/sprites/HUDSprite"

import "scripts/ui/uiConstants"
import "utilities/constants"

local gfx <const> = playdate.graphics

local HUD_CONSTANTS <const> = UI_CONSTANTS.HUD
local LAYERS <const> = CONSTANTS.LAYERS

---@param is_filled boolean
---@nodiscard
---@return _Image
local function buildHeartImage(is_filled)
  local diameter <const> = HUD_CONSTANTS.HEART_DIAMETER
  local height <const> = HUD_CONSTANTS.H

  local image = gfx.image.new(diameter, height)
  assert(image, "Assertion Failed - buildHeartImage image.new returned nil for diameter " .. diameter .. " and height " .. height)

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

---@class HeartSprite: HUDSprite
---@field private is_filled boolean
---@overload fun(x: integer, y: integer): HeartSprite
HeartSprite = class('HeartSprite').extends(HUDSprite --[[@as table]]) or HeartSprite
function HeartSprite:init(x, y)
  HeartSprite.super.init(self, x, y, LAYERS.UI)
  self:setFilled(true)
end

---@param is_filled boolean
function HeartSprite:setFilled(is_filled)
  if (self.is_filled == is_filled) then return end
  self.is_filled = is_filled
  self:setImage(self.is_filled and FILLED_IMAGE or EMPTY_IMAGE)
end
