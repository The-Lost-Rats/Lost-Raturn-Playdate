import "CoreLibs/graphics"
import "CoreLibs/object"

import "constants"
import "states/GameState"

local gfx <const> = playdate.graphics

class('TitleState').extends(GameState)
function TitleState:update()
  gfx.clear()
  gfx.drawText(self.className, CONSTANTS.SCREEN_W_HALF, CONSTANTS.SCREEN_H_HALF, kTextAlignment.center)

  if (playdate.buttonJustPressed(playdate.kButtonA)) then
    setState(STATE_GAME_PLAY)
  end
end
