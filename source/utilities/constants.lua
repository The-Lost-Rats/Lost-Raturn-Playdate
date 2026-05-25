local SCREEN_W <const> = playdate.display.getWidth()
local SCREEN_H <const> = playdate.display.getHeight()

CONSTANTS = {
  SCREEN_W = SCREEN_W,
  SCREEN_H = SCREEN_H,

  SCREEN_W_HALF = SCREEN_W / 2,
  SCREEN_H_HALF = SCREEN_H / 2,

  HUD_H = 24,
  FLOOR_Y = 220,

  TAGS = {
    PLAYER = 1,
    ITEM = 2,
    LEG = 3,
    SHOE = 4
  },

  GROUPS = {
    PLAYER = 1,
    PICK_UP = 2,
    HAZARD = 3,
    CLIMBABLE = 4
  },

  PLAYER = {
    MOVE_SPEED = 4, -- px/frame
    JUMP_V = -9 -- px/frame
  },

  GRAVITY = 0.6, -- px/frame^2

  -- TODO: is this the right format for the constants? Should I have walkers be its own?
  PEDESTRIANS = {
    TYPES = {
      {
        name = "COWBOY",
        item = "SIX_SHOOTER",
        sprite = "cowboy"
      },
      {
        name= "BUSINESS_MAN",
        item = "WATCH",
        sprite = "business_man"
      },
      {
        name = "WOMAN",
        item = "RING",
        sprite = "woman"
      },
      {
        name = "SWIMMER",
        item = "SUNSCREEN",
        sprite = "swimmer"
      },
      {
        name = "CONSTRUCTION_WORKER",
        item = "WRENCH",
        sprite = "construction_worker"
      },
      {
        name = "RUNNER",
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
    },

    -- TODO: do i want an item section?
    ITEM_DROP_CHANCE = 0.65,
    ITEM_SPAWN_LEFT_BOUND = 30,
    ITEM_SPAWN_RIGHT_BOUND = SCREEN_W - 30,
    ITEM_GROUNDED_TIME_MS = 4000,
    ITEM_TTL_MS = 2000,
    ITEM_MAX_BLINK_SPEED_MS = 640,
    ITEM_MIN_BLINK_SPEED_MS = 40
  }
}
