import "utilities/constants"

---@class ItemType
---@field name string
---@field sprite string

local DISPLAY <const> = CONSTANTS.DISPLAY

local ITEM_SPAWN_PADDING <const> = 30

ITEM_CONSTANTS = {
  ---@type table<string, ItemType>
  TYPES = {
    SIX_SHOOTER = { name = "Six Shooter", sprite = "images/items/sunscreen" },
    WATCH = { name = "Watch", sprite = "images/items/sunscreen" },
    RING = { name = "Ring", sprite = "images/items/sunscreen" },
    SUNSCREEN = { name = "Sunscreen", sprite = "images/items/sunscreen" },
    WRENCH = { name = "Wrench", sprite = "images/items/sunscreen" },
    PHONE = { name = "Phone", sprite = "images/items/sunscreen" }
  },

  SPAWN_Y = -10,

  BOB_AMPLITUDE = 15,
  GRAVITY_MULTIPLIER = 0.60,

  GROUNDED_TIME_MS = 4000,
  TTL_MS = 2000,

  MAX_BLINK_SPEED_MS = 640,
  MIN_BLINK_SPEED_MS = 40,
  BLINK_INTERVAL_DIVISOR = 1.5,

  SPAWN_LEFT_BOUND = ITEM_SPAWN_PADDING,
  SPAWN_RIGHT_BOUND = DISPLAY.W - ITEM_SPAWN_PADDING
}
