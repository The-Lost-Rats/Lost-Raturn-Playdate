import "CoreLibs/graphics"
import "CoreLibs/object"

import "states/GameOverState"
import "states/GamePlayState"
import "states/TitleState"

local gfx <const> = playdate.graphics

STATE_TITLE = TitleState()
STATE_GAME_PLAY = GamePlayState()
STATE_GAME_OVER = GameOverState()

local current_game_state = STATE_TITLE
current_game_state:enter()

function setState(new_state)
  current_game_state:leave()
  current_game_state = new_state
  current_game_state:enter()
end

function playdate.update()
  current_game_state:update()
end
