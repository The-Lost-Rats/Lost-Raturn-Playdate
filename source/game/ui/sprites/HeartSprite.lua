-- HeartSprite.lua
-- A single heart (filled or empty).
--

import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

import "game/ui/sprites/HUDSprite"

import "game/ui/uiConstants"
import "game/constants"

local gfx <const> = playdate.graphics

local HUD_CONSTANTS <const> = UI_CONSTANTS.HUD
local LAYERS <const> = CONSTANTS.LAYERS

--- Build sprite images for hearts
---@param is_filled boolean
---@nodiscard
---@return _Image
local function buildHeartImage(is_filled)
  local image_path = is_filled and HUD_CONSTANTS.HEART_FULL_SPRITE
    or HUD_CONSTANTS.HEART_EMPTY_SPRITE

  local image = gfx.image.new(image_path)
  assert(image, "Assertion Failed - could not load image for heart at " .. image_path)

  return image
end

local FILLED_IMAGE <const> = buildHeartImage(true)
local EMPTY_IMAGE <const> = buildHeartImage(false)

---@class HeartSprite: HUDSprite
---@field private is_filled boolean
---@overload fun(x: integer, y: integer): HeartSprite
HeartSprite = class("HeartSprite").extends(HUDSprite --[[@as table]]) or HeartSprite
function HeartSprite:init(x, y)
  HeartSprite.super.init(self, x, y, LAYERS.UI)
  -- Veritically center sprites
  self:setCenter(0, 0.5)
  self:setFilled(true)
end

---@param is_filled boolean
function HeartSprite:setFilled(is_filled)
  if self.is_filled == is_filled then return end
  self.is_filled = is_filled
  self:setImage(self.is_filled and FILLED_IMAGE or EMPTY_IMAGE)
end
