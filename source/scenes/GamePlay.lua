import "CoreLibs/graphics"
import "CoreLibs/object"

import "scenes/BaseScene"
import "scripts/Player"
import "utilities/constants"

local gfx <const> = playdate.graphics

class ('GamePlay').extends(BaseScene)
function GamePlay:enter()
  self.player = Player(0, 0, 1, true)
  self.player:moveTo(CONSTANTS.SCREEN_W_HALF, CONSTANTS.FLOOR_Y - self.player.height / 2)
  self.player:setVisible(true)
  self.player:add()

  gfx.sprite.setBackgroundDrawingCallback(function(x, y, w, h)
    gfx.setColor(gfx.kColorBlack)

    local display_text = self.className
    local text_w, text_h = gfx.getTextSize(display_text)
    gfx.drawText(display_text, CONSTANTS.SCREEN_W_HALF - text_w / 2, CONSTANTS.SCREEN_H_HALF - text_h / 2)

    -- TODO: eventually create UI manager? Make this a sprite maybe?
    -- Floor line
    gfx.drawLine(0, CONSTANTS.FLOOR_Y, CONSTANTS.SCREEN_W, CONSTANTS.FLOOR_Y)

    -- HUD Box
    gfx.fillRect(0, 0, CONSTANTS.SCREEN_W, CONSTANTS.HUD_H)
    
    gfx.setColor(gfx.kColorWhite)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawText("Score: 0", 4, 4) -- TODO: make these constants or something

    -- TODO: these should not be hard coded - num hears should be here, loop, math to place
    gfx.fillCircleInRect(CONSTANTS.SCREEN_W - 20, 0, 10, CONSTANTS.HUD_H)
    gfx.fillCircleInRect(CONSTANTS.SCREEN_W - 40, 0, 10, CONSTANTS.HUD_H)
    gfx.fillCircleInRect(CONSTANTS.SCREEN_W - 60, 0, 10, CONSTANTS.HUD_H)
    
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    gfx.setColor(gfx.kColorBlack)
  end)
end

function GamePlay:update()
  gfx.sprite.update()

  if (playdate.buttonJustPressed(playdate.kButtonA)) then
    setScene(SCENE_GAME_OVER)
  end
end
