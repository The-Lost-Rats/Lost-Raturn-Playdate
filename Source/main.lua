import "CoreLibs/graphics"
import "CoreLibs/object"

local gfx <const> = playdate.graphics

local screen_height <const> = playdate.display.getHeight()
local screen_width <const> = playdate.display.getWidth()

local STATE_TITLE, STATE_GAME_PLAY, STATE_GAME_OVER

-- TODO: should i move these to new files?
class ('GameState').extends()
function GameState:enter() end
function GameState:leave() end
function GameState:update() error("update() not implemented in subclass!") end

class('TitleState').extends(GameState)
function TitleState:update()
  gfx.clear()
  gfx.drawText(self.className, screen_width / 2, screen_height / 2, kTextAlignment.center)

  if (playdate.buttonJustPressed(playdate.kButtonA)) then
    setState(STATE_GAME_PLAY)
  end
end

class ('GamePlayState').extends(GameState)
function GamePlayState:update()
  gfx.clear()
  gfx.drawText(self.className, screen_width / 2, screen_height / 2, kTextAlignment.center)

  if (playdate.buttonJustPressed(playdate.kButtonA)) then
    setState(STATE_GAME_OVER)
  end
end

class('GameOverState').extends(GameState)
function GameOverState:update()
  gfx.clear()
  gfx.drawText(self.className, screen_width / 2, screen_height / 2, kTextAlignment.center)

  if (playdate.buttonJustPressed(playdate.kButtonA)) then
    setState(STATE_TITLE)
  end
end

STATE_TITLE = TitleState()
STATE_GAME_PLAY = GamePlayState()
STATE_GAME_OVER = GameOverState()

local current_game_state = STATE_TITLE

function setState(new_state)
  current_game_state:leave()
  current_game_state = new_state
  current_game_state:enter()
end

function playdate.update()
  current_game_state:update()
end
