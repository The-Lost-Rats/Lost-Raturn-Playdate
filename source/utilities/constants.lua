local SCREEN_W <const> = playdate.display.getWidth()
local SCREEN_H <const> = playdate.display.getHeight()

CONSTANTS = {
  SCREEN_W = SCREEN_W,
  SCREEN_H = SCREEN_H,

  SCREEN_W_HALF = SCREEN_W / 2,
  SCREEN_H_HALF = SCREEN_H / 2,

  HUD_H = 24,
  FLOOR_Y = 220,

  PLAYER = {
    MOVE_SPEED = 4, -- px/frame
    JUMP_V = -9 -- px/frame
  },

  GRAVITY = 0.6 -- px/frame^2
}
