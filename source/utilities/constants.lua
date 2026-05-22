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

  -- TODO: is this the right format for the constants? Should I have walkers be its own?
  PEDESTRIANS = {
    TYPES = {
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
      }
    },

    STEP_LENGTH = 120,
    LEG_SPACING = 40,

    SPAWN_POSITION_LEFT = -20,
    SPAWN_POSITION_RIGHT = SCREEN_W + 20, -- TODO: 20 should not be hardcoded
    DESPAWN_BOUND_LEFT = -40,
    DESPAWN_BOUND_RIGHT = SCREEN_W + 40,

    MAX_WALKERS = 6,
    MIN_WALKERS = 2,

    MIN_SPAWN_INTERVAL_MS = 1000,
    MAX_SPAWN_INTERVAL_MS = 8000,

    -- TODO: do i want this?
    DIRECTION = {
      LEFT = 0,
      RIGHT = 1
    }
  }
}
