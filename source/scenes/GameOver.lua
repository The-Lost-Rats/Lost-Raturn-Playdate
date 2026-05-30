import "CoreLibs/graphics"
import "CoreLibs/object"

import "scenes/BaseScene"
import "utilities/constants"

local gfx <const> = playdate.graphics

local DISPLAY <const> = CONSTANTS.DISPLAY

class('GameOver').extends(BaseScene)
function GameOver:update()
  local display_text = self.className
  local text_w, text_h = gfx.getTextSize(display_text)

  gfx.clear()
  gfx.drawText(display_text, DISPLAY.W_HALF - text_w / 2, DISPLAY.H_HALF - text_h / 2)

  if (playdate.buttonJustPressed(playdate.kButtonA)) then
    setScene(SCENE_TITLE)
  end
end
