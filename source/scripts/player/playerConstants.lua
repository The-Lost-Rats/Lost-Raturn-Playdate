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
    PIXELS_PER_DEGREE = 0.17, -- crank delta to pixels (crank sensitivity)
    MAX_ACCELERATED_CHANGE = 60, -- crank cap so player cannot go super fast
  },

  MAX_HEALTH = 3,

  HELD_ITEM_Y_GAP = 4,

  ---@enum AnimationState
  ANIMATION = {
    IDLE = "idle",
    RUN = "run",
    JUMP = "jump",
    CLIMB = "climb",
  },
}
