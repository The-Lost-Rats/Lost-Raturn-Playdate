-- walkerConstants.lua
-- Tuning values for walker behaviour and walker registry (type -> item, sprite etc.)
--

import "game/constants"
import "game/entities/item/itemConstants"

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

WALKER_CONSTANTS = {
  ---@type WalkerType[]
  TYPES = {
    {
      name = "COWBOY",
      item = ITEM_TYPES.SIX_SHOOTER,
      sprite = {
        path = "images/walkers/cowboy",
        leg_rect = { 37, 0, 42, 215 },
        shoe_rect = { 5, 217, 74, 9 },
      },
    },
    {
      name = "BUSINESS_MAN",
      item = ITEM_TYPES.WATCH,
      sprite = {
        path = "images/walkers/business_man",
        leg_rect = { 36, 0, 52, 207 },
        shoe_rect = { 5, 216, 76, 12 },
      },
    },
    {
      name = "DANCER",
      item = ITEM_TYPES.RING,
      sprite = {
        path = "images/walkers/dancer",
        leg_rect = { 36, 0, 49, 214 },
        shoe_rect = { 12, 216, 70, 12 },
      },
    },
    {
      name = "SWIMMER",
      item = ITEM_TYPES.SUNSCREEN,
      sprite = {
        path = "images/walkers/swimmer",
        leg_rect = { 41, 0, 47, 212 },
        shoe_rect = { 18, 212, 62, 16 },
      },
    },
    {
      name = "CONSTRUCTION_WORKER",
      item = ITEM_TYPES.WRENCH,
      sprite = {
        path = "images/walkers/construction_worker",
        leg_rect = { 36, 0, 47, 204 },
        shoe_rect = { 12, 216, 70, 12 },
      },
    },
    {
      name = "RUNNER",
      item = ITEM_TYPES.PHONE,
      sprite = {
        path = "images/walkers/runner",
        leg_rect = { 47, 0, 34, 202 },
        shoe_rect = { 9, 214, 75, 14 },
      },
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
