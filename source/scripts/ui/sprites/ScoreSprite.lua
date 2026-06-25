import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

import "scripts/ui/sprites/HUDSprite"

import "scripts/ui/uiConstants"
import "utilities/constants"

local gfx <const> = playdate.graphics

local LAYERS <const> = CONSTANTS.LAYERS

---@class ScoreSprite: HUDSprite
---@field x integer
---@field y integer
---@overload fun(x: integer, y: integer): ScoreSprite
ScoreSprite = class('ScoreSprite').extends(HUDSprite --[[@as table]]) or ScoreSprite
function ScoreSprite:init(x, y)
  ScoreSprite.super.init(self, x, y, LAYERS.UI)
  self:setScore(0)
end

function ScoreSprite:setScore(score)
  if (self.score == score) then return end
  self.score = score

  local score_string = "Score: " .. self.score

  local image = gfx.image.new(gfx.getTextSize(score_string))
  gfx.pushContext(image)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawText(score_string, 0, 0)
  gfx.popContext()

  self:setImage(image)
end
