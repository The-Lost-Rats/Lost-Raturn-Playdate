-- walkerConstants.lua
-- Tuning values for walker behaviour and walker registry (type -> item, sprite etc.)
--

import "utilities/constants"
import "scripts/item/itemConstants"

---@class WalkerType
---@field name string
---@field item ItemType

local ITEM_TYPES <const> = ITEM_CONSTANTS.TYPES

local DISPLAY <const> = CONSTANTS.DISPLAY
local LEG_H <const> = DISPLAY.H

local WALKER_SPAWN_PADDING <const> = 20
local WALKER_DESPAWN_PADDING <const> = 40

WALKER_CONSTANTS = {
  LEG_SCORE_PERCENT = 0.90, -- Climb above 90% of leg to enter score range

  LEG_W = 16,
  LEG_H = LEG_H,

  SHOE_W = 32,
  SHOE_H = 20,

  ---@type WalkerType[]
  TYPES = {
    {
      name = "COWBOY",
      item = ITEM_TYPES.SIX_SHOOTER
    },
    {
      name = "BUSINESS_MAN",
      item = ITEM_TYPES.WATCH
    },
    {
      name = "WOMAN",
      item = ITEM_TYPES.RING
    },
    {
      name = "SWIMMER",
      item = ITEM_TYPES.SUNSCREEN
    },
    {
      name = "CONSTRUCTION_WORKER",
      item = ITEM_TYPES.WRENCH
    },
    {
      name = "RUNNER",
      item = ITEM_TYPES.PHONE
    }
  },

  STEP_LENGTH = 120,
  LEG_SPACING = 40,

  SPAWN_POSITION_LEFT = -WALKER_SPAWN_PADDING,
  SPAWN_POSITION_RIGHT = DISPLAY.W + WALKER_SPAWN_PADDING,
  DESPAWN_BOUND_LEFT = -WALKER_DESPAWN_PADDING,
  DESPAWN_BOUND_RIGHT = DISPLAY.W + WALKER_DESPAWN_PADDING,

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
