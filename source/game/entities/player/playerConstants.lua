-- playerConstants.lua
-- Player tuning: movement/jump velocity, climbing, health, animation states.
--

PLAYER_CONSTANTS = {
  -- px/frame
  MOVE_SPEED = 5,
  JUMP_V = -9,
  HIT_KNOCKBACK_V = -9,
  DISMOUNT_V = -9,

  CLIMBING = {
    PIXELS_PER_DEGREE = 0.35, -- crank delta to pixels (crank sensitivity)
    MAX_ACCELERATED_CHANGE = 60, -- crank cap so player cannot go super fast
  },

  MAX_HEALTH = 3,

  HELD_ITEM_Y_GAP = 4,

  ---@enum AnimationStateEnum
  ANIMATION = {
    IDLE = "idle",
    RUN = "run",
    JUMP = "jump",
    CLIMB = "climb",
  },

  JUMP_FRAME = {
    CROUCH = 1,
    RISE = 2,
    HANG = 3,
    FALL = 4,
    LAND_SQUISH = 5,
    LAND_POP_UP = 6,
  },

  APEX_VY = 2,
}
