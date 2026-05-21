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

  GRAVITY = 0.6, -- px/frame^2

  PEDESTRIANS = {
    COWBOY = {
      item = "SIX_SHOOTER",
      sprite = "cowboy"
    },
    BUSINESS_MAN = {
      item = "WATCH",
      sprite = "business_man"
    },
    WOMAN = {
      item = "RING",
      sprite = "woman"
    },
    SWIMMER = {
      item = "SUNSCREEN",
      sprite = "swimmer"
    },
    CONSTRUCTION_WORKER = {
      item = "WRENCH",
      sprite = "construction_worker"
    },
    RUNNER = {
      item = "PHONE",
      sprite = "runner"
    },

    STEP_LENGTH = 100
  }
}
