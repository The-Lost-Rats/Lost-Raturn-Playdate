import "CoreLibs/graphics"
import "CoreLibs/object"

import "scenes/GameOver"
import "scenes/GamePlay"
import "scenes/Title"

local gfx <const> = playdate.graphics
playdate.display.setRefreshRate(30)

SCENE_TITLE = Title()
SCENE_GAME_PLAY = GamePlay()
SCENE_GAME_OVER = GameOver()

local current_game_state = SCENE_TITLE
current_game_state:enter()

function setState(new_state)
  current_game_state:leave()
  current_game_state = new_state
  current_game_state:enter()
end

function playdate.update()
  current_game_state:update()
end
