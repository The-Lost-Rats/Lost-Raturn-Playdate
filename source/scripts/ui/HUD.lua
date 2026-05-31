import "CoreLibs/object"

import "scripts/ui/sprites/HUDBackgroundSprite"
import "scripts/ui/sprites/HeartSprite"
import "scripts/ui/sprites/ScoreSprite"
import "utilities/constants"

local PLAYER <const> = CONSTANTS.PLAYER
local DISPLAY <const> = CONSTANTS.DISPLAY

class ('HUD').extends()
function HUD:init()
  self.hud_background_sprite = HUDBackgroundSprite(0, 0)
  self.score_sprite = ScoreSprite(CONSTANTS.HUD.SCORE_X, CONSTANTS.HUD.SCORE_Y)
  self.heart_sprites = {}

  for i = 1, PLAYER.MAX_HEALTH do
    local x = DISPLAY.W - CONSTANTS.HUD.HEART_SPACING * i
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