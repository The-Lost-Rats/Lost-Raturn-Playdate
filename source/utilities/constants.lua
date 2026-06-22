local SCREEN_W <const> = playdate.display.getWidth()
local SCREEN_H <const> = playdate.display.getHeight()

local WALKER_SPAWN_PADDING <const> = 20
local WALKER_DESPAWN_PADDING <const> = 40

local ITEM_SPAWN_PADDING <const> = 30

local FLOOR_Y_PADDING <const> = 20

local LEG_H <const> = SCREEN_H

-- TODO: maybe we make this local and use immutable getters
CONSTANTS = {
  DISPLAY = {
    W = SCREEN_W,
    H = SCREEN_H,
    W_HALF = SCREEN_W / 2,
    H_HALF = SCREEN_H / 2,
    REFRESH_RATE = 30,
  },

  WORLD = {
    W = SCREEN_W,
    FLOOR_Y = SCREEN_H - FLOOR_Y_PADDING,
  },

  PHYSICS = {
    GRAVITY = 0.6, -- px/frame^2
  },

  LAYERS = {
    UI = 2,
    UI_BACKGROUND = 1,
    ITEM = 0,
    PLAYER = -1,
    WALKER = -2
  },

  HUD = {
    H = 24,

    SCORE_X = 4,
    SCORE_Y = 4,

    HEART_SPACING = 20,
    HEART_DIAMETER = 10,
  },

  DIRECTION = {
    LEFT = 0,
    RIGHT = 1
  },

  -- Tags and groups for collision detection
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
    -- px/frame
    MOVE_SPEED = 5,
    JUMP_V = -9,
    HIT_KNOCKBACK_V = -9,
    DISMOUNT_V = -9,

    MAX_HEALTH = 3,

    HELD_ITEM_Y_GAP = 4,

    ANIMATION = {
      IDLE = "idle",
      RUN = "run",
      JUMP = "jump",
      CLIMB = "climb"
    }
  },

  CLIMBING = {
    PIXELS_PER_DEGREE = 0.08,
    MAX_ACCELERATED_CHANGE = 60,
    LEG_SCORE_DISTANCE = LEG_H * 0.90 -- Climb above 90% of leg to enter score range
  },

  SCORING = {
    CORRECT_DELIVERY = 100,
    WRONG_DELIVERY = -50,
  },

  ITEM = {
    W = 8,
    H = 8,

    SPAWN_Y = -10,

    BOB_AMPLITUDE = 15,
    GRAVITY_MULTIPLIER = 0.60,

    GROUNDED_TIME_MS = 4000,
    TTL_MS = 2000,

    MAX_BLINK_SPEED_MS = 640,
    MIN_BLINK_SPEED_MS = 40,
    BLINK_INTERVAL_DIVISOR = 1.5,

    SPAWN_LEFT_BOUND = ITEM_SPAWN_PADDING,
    SPAWN_RIGHT_BOUND = SCREEN_W - ITEM_SPAWN_PADDING
  },
    
  PEDESTRIANS = {
    LEG_W = 16,
    LEG_H = LEG_H,

    SHOE_W = 32,
    SHOE_H = 20,

    TYPES = {
      {
        name = "COWBOY",
        item = "SIX_SHOOTER",
      },
      {
        name = "BUSINESS_MAN",
        item = "WATCH",
      },
      {
        name = "WOMAN",
        item = "RING",
      },
      {
        name = "SWIMMER",
        item = "SUNSCREEN",
      },
      {
        name = "CONSTRUCTION_WORKER",
        item = "WRENCH",
      },
      {
        name = "RUNNER",
        item = "PHONE",
      }
    },

    STEP_LENGTH = 120,
    LEG_SPACING = 40,

    SPAWN_POSITION_LEFT = -WALKER_SPAWN_PADDING,
    SPAWN_POSITION_RIGHT = SCREEN_W + WALKER_SPAWN_PADDING,
    DESPAWN_BOUND_LEFT = -WALKER_DESPAWN_PADDING,
    DESPAWN_BOUND_RIGHT = SCREEN_W + WALKER_DESPAWN_PADDING,

    MIN_WALKERS = 2,
    MAX_WALKERS = 6,

    MIN_SPAWN_INTERVAL_MS = 1000,
    MAX_SPAWN_INTERVAL_MS = 8000,

    SPAWN_CAP_RAMP = 0.5,
    SPAWN_INTERVAL_RAMP_MS = 100,

    RIGHT_VX = 5,
    LEFT_VX = -5,
    VY = -5,

    ITEM_DROP_CHANCE = 0.65,

    STOMP_DAMAGE = 1,
  }
}
