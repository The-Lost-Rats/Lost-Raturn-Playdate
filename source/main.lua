import "CoreLibs/graphics"
import "CoreLibs/timer"

import "scenes/GameOver"
import "scenes/GamePlay"
import "scenes/Title"
import "utilities/constants"

local gfx <const> = playdate.graphics
local timer <const> = playdate.timer

local DISPLAY <const> = CONSTANTS.DISPLAY

playdate.display.setRefreshRate(DISPLAY.REFRESH_RATE)

math.randomseed(playdate.getSecondsSinceEpoch())

SCENE_TITLE = Title()
SCENE_GAME_PLAY = GamePlay()
SCENE_GAME_OVER = GameOver()

local current_game_scene = SCENE_TITLE
current_game_scene:enter()

function setScene(new_state)
  current_game_scene:leave()
  current_game_scene = new_state
  current_game_scene:enter()
end

function playdate.update()
  timer.updateTimers()
  current_game_scene:update()
end
