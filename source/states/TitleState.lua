import "CoreLibs/graphics"
import "CoreLibs/object"

import "constants"
import "states/GameState"

local gfx <const> = playdate.graphics

class('TitleState').extends(GameState)
function TitleState:update()
  local display_text = self.className
  local text_w, text_h = gfx.getTextSize(display_text)

  gfx.clear()
  gfx.drawText(display_text, CONSTANTS.SCREEN_W_HALF - text_w / 2, CONSTANTS.SCREEN_H_HALF - text_h / 2, kTextAlignment.center)

  if (playdate.buttonJustPressed(playdate.kButtonA)) then
    setState(STATE_GAME_PLAY)
  end
end
