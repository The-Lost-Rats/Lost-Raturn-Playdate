import "CoreLibs/object"

import "scripts/ui/sprites/HUDBackgroundSprite"
import "scripts/ui/sprites/HeartSprite"
import "scripts/ui/sprites/ScoreSprite"

import "scripts/ui/uiConstants"
import "utilities/constants"

local DISPLAY <const> = CONSTANTS.DISPLAY
local HUD_CONSTANTS <const> = UI_CONSTANTS.HUD

---@class HUD: _Object
---@field max_health integer
---@overload fun(max_health: integer): HUD
HUD = class ('HUD').extends() or HUD
function HUD:init(max_health)
  self.hud_background_sprite = HUDBackgroundSprite(0, 0)
  self.score_sprite = ScoreSprite(HUD_CONSTANTS.SCORE_X, HUD_CONSTANTS.SCORE_Y)
  self.heart_sprites = {}

  for i = 1, max_health do
    local x = DISPLAY.W - HUD_CONSTANTS.HEART_SPACING * i
    self.heart_sprites[i] = HeartSprite(x, 0)
  end
end

function HUD:add()
  self.hud_background_sprite:add()
  self.score_sprite:add()

  for _, sprite in ipairs(self.heart_sprites) do
    sprite:add()
  end
end

function HUD:remove()
  self.hud_background_sprite:remove()
  self.score_sprite:remove()

  for _, sprite in ipairs(self.heart_sprites) do
    sprite:remove()
  end
end

function HUD:setScore(score)
  self.score_sprite:setScore(score)
end

function HUD:setHealth(health)
  for i, sprite in ipairs(self.heart_sprites) do
    sprite:setFilled(i <= health)
  end
end