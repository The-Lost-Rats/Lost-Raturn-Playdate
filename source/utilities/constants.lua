local SCREEN_W <const> = playdate.display.getWidth()
local SCREEN_H <const> = playdate.display.getHeight()

local FLOOR_Y_PADDING <const> = 20

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

  ---@enum Layer
  LAYERS = {
    UI = 2,
    UI_BACKGROUND = 1,
    ITEM = 0,
    PLAYER = -1,
    WALKER = -2
  },

  -- Tags and groups for collision detection
  ---@enum Tag
  TAGS = {
    PLAYER = 1,
    ITEM = 2,
    LEG = 3,
    SHOE = 4
  },

  ---@enum Group
  GROUPS = {
    PLAYER = 1,
    PICK_UP = 2,
    HAZARD = 3,
    CLIMBABLE = 4
  },

  ---@enum Direction
  DIRECTION = {
    LEFT = 0,
    RIGHT = 1
  }
}
