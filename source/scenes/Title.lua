import "CoreLibs/graphics"
import "CoreLibs/object"

import "utilities/constants"
import "scenes/BaseScene"

local gfx <const> = playdate.graphics

class('Title').extends(BaseScene)
function Title:update()
  local display_text = self.className
  local text_w, text_h = gfx.getTextSize(display_text)

  gfx.clear()
  gfx.drawText(display_text, CONSTANTS.SCREEN_W_HALF - text_w / 2, CONSTANTS.SCREEN_H_HALF - text_h / 2)

  if (playdate.buttonJustPressed(playdate.kButtonA)) then
    setScene(SCENE_GAME_PLAY)
  end
end
