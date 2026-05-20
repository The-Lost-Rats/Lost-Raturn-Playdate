import "CoreLibs/graphics"
import "CoreLibs/object"

import "utilities/constants"
import "scenes/BaseScene"

local gfx <const> = playdate.graphics

class ('GamePlay').extends(BaseScene)
function GamePlay:update()
  local display_text = self.className
  local text_w, text_h = gfx.getTextSize(display_text)

  gfx.setColor(gfx.kColorBlack)
  gfx.clear()

  gfx.drawText(display_text, CONSTANTS.SCREEN_W_HALF - text_w / 2, CONSTANTS.SCREEN_H_HALF - text_h / 2)

  -- TODO: eventually create UI manager?
  -- Floor line
  gfx.drawLine(0, CONSTANTS.FLOOR_Y, CONSTANTS.SCREEN_W, CONSTANTS.FLOOR_Y)

  -- HUD Box
  gfx.fillRect(0, 0, CONSTANTS.SCREEN_W, CONSTANTS.HUD_H)
  
  gfx.setColor(gfx.kColorWhite)
  gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
  gfx.drawText("Score: 0", 4, 4) -- TODO: make these constants or something

  -- TODO: these should not be hard coded - num hears should be here, loop, math to place
  playdate.graphics.drawCircleInRect(CONSTANTS.SCREEN_W - 20, 0, 10, CONSTANTS.HUD_H)
  playdate.graphics.drawCircleInRect(CONSTANTS.SCREEN_W - 40, 0, 10, CONSTANTS.HUD_H)
  playdate.graphics.drawCircleInRect(CONSTANTS.SCREEN_W - 60, 0, 10, CONSTANTS.HUD_H)
  
  gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
  gfx.setColor(gfx.kColorBlack)

  if (playdate.buttonJustPressed(playdate.kButtonA)) then
    setScene(SCENE_GAME_OVER)
  end
end
