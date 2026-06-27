-- main.lua
-- Constructs the scenes, wires scene switching, and runs the frame loop.
--

import "CoreLibs/graphics"
import "CoreLibs/timer"

import "scenes/GameOver"
import "scenes/GamePlay"
import "scenes/Title"
import "utilities/constants"

local timer <const> = playdate.timer

local DISPLAY <const> = CONSTANTS.DISPLAY

playdate.display.setRefreshRate(DISPLAY.REFRESH_RATE)

math.randomseed(playdate.getSecondsSinceEpoch())

SCENE_TITLE = Title()
SCENE_GAME_PLAY = GamePlay()
SCENE_GAME_OVER = GameOver()

---@type BaseScene
local current_game_scene = SCENE_TITLE
current_game_scene:enter()

--- Switches active scene to new scene: leave() the current one, enter() the next.
---@param new_scene BaseScene
function setScene(new_scene)
  current_game_scene:leave()
  current_game_scene = new_scene
  current_game_scene:enter()
end

function playdate.update()
  -- Update timers across the entire system
  timer.updateTimers()
  current_game_scene:update()
end
