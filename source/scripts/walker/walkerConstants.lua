-- walkerConstants.lua
-- Tuning values for walker behaviour and walker registry (type -> item, sprite etc.)
--

import "utilities/constants"
import "scripts/item/itemConstants"

---@class WalkerSprite
---@field path string
---@field leg_rect HitBox Collider for player to climb
---@field shoe_rect HitBox Collider for shoe to hit player

---@class WalkerType
---@field name string
---@field item ItemType
---@field sprite WalkerSprite

local ITEM_TYPES <const> = ITEM_CONSTANTS.TYPES

local DISPLAY <const> = CONSTANTS.DISPLAY

local WALKER_SPAWN_PADDING <const> = 20
local WALKER_DESPAWN_PADDING <const> = 40

--- Temporary constant sprite shared for all walkers
---@type WalkerSprite
local SWIMMER_SPRITE <const> = {
  path = "images/walkers/swimmer",
  leg_rect = { 41, 0, 47, 212 },
  shoe_rect = { 18, 212, 62, 16 },
}

WALKER_CONSTANTS = {
  ---@type WalkerType[]
  TYPES = {
    {
      name = "COWBOY",
      item = ITEM_TYPES.SIX_SHOOTER,
      sprite = SWIMMER_SPRITE,
    },
    {
      name = "BUSINESS_MAN",
      item = ITEM_TYPES.WATCH,
      sprite = SWIMMER_SPRITE,
    },
    {
      name = "WOMAN",
      item = ITEM_TYPES.RING,
      sprite = SWIMMER_SPRITE,
    },
    {
      name = "SWIMMER",
      item = ITEM_TYPES.SUNSCREEN,
      sprite = SWIMMER_SPRITE,
    },
    {
      name = "CONSTRUCTION_WORKER",
      item = ITEM_TYPES.WRENCH,
      sprite = SWIMMER_SPRITE,
    },
    {
      name = "RUNNER",
      item = ITEM_TYPES.PHONE,
      sprite = SWIMMER_SPRITE,
    },
  },

  LEG_SCORE_PERCENT = 0.90, -- Climb above 90% of leg to enter score range

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
