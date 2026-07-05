-- GamePlay.lua
-- Core game play scene. Manages player, walkers, UI.
--

import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/timer"
import "CoreLibs/ui"

import "game/scenes/BaseScene"

import "game/entities/walker/Walker"
import "game/entities/player/Player"
import "game/systems/ScoreManager"
import "game/ui/HUD"

import "game/entities/player/playerConstants"
import "game/entities/walker/walkerConstants"
import "game/constants"

local gfx <const> = playdate.graphics
local timer <const> = playdate.timer
local ui <const> = playdate.ui

local DISPLAY <const> = CONSTANTS.DISPLAY
local WORLD <const> = CONSTANTS.WORLD

local DIRECTION <const> = CONSTANTS.DIRECTION

local WALKERS <const> = WALKER_CONSTANTS
local PLAYER <const> = PLAYER_CONSTANTS

---@class GamePlay: BaseScene
---@field hud HUD
---@field score_manager ScoreManager
---@field player Player
---@field walkers Walker[]
---@field walkers_spawn_cap number
---@field walkers_spawn_interval_ms number
---@field walker_timer? _Timer
---@overload fun(): GamePlay
GamePlay = class("GamePlay").extends(BaseScene) or GamePlay

--#region _____________________________  Init/Enter/Leave  _____________________________

function GamePlay:init()
  GamePlay.super.init(self)

  self.hud = HUD(PLAYER.MAX_HEALTH)
  self.score_manager = ScoreManager()

  self.player = Player(DISPLAY.W_HALF, WORLD.FLOOR_Y, PLAYER.MAX_HEALTH, {
    on_deliver = function(item_type, leg_type)
      local result = self.score_manager:recordDelivery(item_type, leg_type)
      self.hud:setScore(result.total)

      return result
    end,
  })

  ---@param health integer
  self.player.on_health_changed:subscribe(function(health) self.hud:setHealth(health) end)

  local background_image_path = "images/background"
  local background_image = gfx.image.new(background_image_path)
  assert(
    background_image,
    "Assertion Failed - could not load image for background at " .. background_image_path
  )

  gfx.sprite.setBackgroundDrawingCallback(function(x, y, w, h)
    -- Redraw background elements and clip to dirty rect
    background_image:draw(0, 0)
  end)

  Walker.preloadImages()
end

function GamePlay:enter()
  self.player:reset()
  self.player:add()

  self.score_manager:reset()
  self.hud:add()
  self.hud:setScore(self.score_manager:getScore())
  self.hud:setHealth(self.player:getCurrentHealth())

  -- Start with a small number of walkers to let the player get used to the game.
  -- And longest spawn interval so they are created really slowly.
  -- Then ramp up slowly.
  self.walkers = {}
  self.walkers_spawn_cap = WALKERS.MIN_WALKERS
  self.walkers_spawn_interval_ms = WALKERS.MAX_SPAWN_INTERVAL_MS

  -- Start the walker spawning process
  self:trySpawnWalker()
end

function GamePlay:leave()
  if self.walker_timer ~= nil then self.walker_timer:remove() end

  self.player:remove()

  for _, walker in ipairs(self.walkers) do
    walker:remove()
  end

  self.hud:remove()
end
--#endregion

--#region _____________________________  Update  _____________________________

function GamePlay:update()
  for _, walker in ipairs(self.walkers) do
    walker:update()
  end

  -- Clean up walkers off screen
  for i = #self.walkers, 1, -1 do
    local walker = self.walkers[i]
    if walker:isOffScreen() then
      walker:remove()
      table.remove(self.walkers, i)
    end
  end

  -- Update sprites last to draw at new positions
  gfx.sprite.update()

  -- Show crank indicator when player needs it and docked
  if playdate.isCrankDocked() and self.player:usesCrank() then ui.crankIndicator:draw() end

  if self.player:isDone() then setScene(SCENE_GAME_OVER) end
end
--#endregion

--#region _____________________________  Walker Spawning _____________________________

--- Spawn a walker if we are under the current walker cap count.
--- Ramps the spawn interval down so walkers spawn faster as the game goes on and
--- ramps the walker cap up so more walkers spawn as the game goes on.
function GamePlay:trySpawnWalker()
  if #self.walkers < self.walkers_spawn_cap then
    self:spawnWalker()
    self.walkers_spawn_cap =
      math.min(WALKERS.MAX_WALKERS, self.walkers_spawn_cap + WALKERS.SPAWN_CAP_RAMP)
    self.walkers_spawn_interval_ms = math.max(
      WALKERS.MIN_SPAWN_INTERVAL_MS,
      self.walkers_spawn_interval_ms - WALKERS.SPAWN_INTERVAL_RAMP_MS
    )
  end

  self.walker_timer = timer.performAfterDelay(
    self.walkers_spawn_interval_ms,
    function() self:trySpawnWalker() end
  )
end

function GamePlay:spawnWalker()
  local random_float = math.random()

  local walker_type_index = math.random(#WALKERS.TYPES)
  local walker_type = WALKERS.TYPES[walker_type_index]

  local direction = random_float >= 0.5 and DIRECTION.LEFT or DIRECTION.RIGHT

  local new_walker = Walker.spawn(walker_type, direction)
  table.insert(self.walkers, new_walker)
end
--#endregion
