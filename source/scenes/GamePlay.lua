import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/timer"
import "CoreLibs/ui"

import "scenes/BaseScene"
import "scripts/pedestrian/Walker"
import "scripts/Player"
import "scripts/ui/HUD"
import "utilities/constants"

local gfx <const> = playdate.graphics
local timer <const> = playdate.timer
local ui <const> = playdate.ui

local DISPLAY <const> = CONSTANTS.DISPLAY
local WORLD <const> = CONSTANTS.WORLD

local DIRECTION <const> = CONSTANTS.DIRECTION
local PEDESTRIANS <const> = CONSTANTS.PEDESTRIANS
local PLAYER <const> = CONSTANTS.PLAYER


-- TODO: should we have itemsbe tracked here? so i can remove items if they are lingering on game over or something?
class ('GamePlay').extends(BaseScene)
function GamePlay:init()
  -- TODO: should i set center of sprites to like bottom center?
  GamePlay.super.init(self)

  self.hud = HUD()

  self.player = Player(0, 0, 1, PLAYER.MAX_HEALTH, self)

  -- Start with a small number of walkers to let the player get used to the game.
  -- And longest spawn interval so they are created really slowly.
  -- Then ramp up slowly.
  self.walkers = {}
  self.walkers_spawn_cap = PEDESTRIANS.MIN_WALKERS
  self.walkers_spawn_interval_ms = PEDESTRIANS.MAX_SPAWN_INTERVAL_MS
end

function GamePlay:enter()
  self.player:reset()
  self.player:add()
  self.current_score = 0

  self.hud:add()
  self.hud:setScore(self.current_score)
  self.hud:setHealth(self.player:getCurrentHealth())

  -- Start the walker spawning process
  self:trySpawnWalker()

  gfx.sprite.setBackgroundDrawingCallback(function(x, y, w, h)
    -- Redraw background elements and clip to dirty rect
    gfx.pushContext()
      gfx.setColor(gfx.kColorBlack)

      -- Floor line
      gfx.drawLine(0, WORLD.FLOOR_Y, DISPLAY.W, WORLD.FLOOR_Y)
    gfx.popContext()
  end)
end

function GamePlay:update()
  for _, walker in ipairs(self.walkers) do
    walker:update()
  end

  -- Clean up walkers off screen
  -- TODO: this is not very performant ;-;
  -- TODO: maybe we can also make this a callback or something? remove when ready...
  for i = #self.walkers, 1, -1 do
    local walker = self.walkers[i]
    if (walker:isOffScreen()) then
      walker:remove()
      table.remove(self.walkers, i)
    end
  end

  -- Update sprites last to draw at new positions
  gfx.sprite.update()

  -- Show crank indicator when climbing and docked
  -- TODO: should we just show this at the start?
  if (playdate.isCrankDocked() and self.player:isClimbing()) then
    ui.crankIndicator:draw()
  end

  if (self.player:isDead()) then
    setScene(SCENE_GAME_OVER)
  end
end

function GamePlay:leave()
  if (self.walker_timer ~= nil) then
    self.walker_timer:remove()
  end

  self.player:remove()

  for _, walker in ipairs(self.walkers) do
    walker:remove()
  end

  self.hud:remove()
end

function GamePlay:trySpawnWalker()
  if (#self.walkers < self.walkers_spawn_cap) then
    self:spawnWalker()
    self.walkers_spawn_cap = math.min(PEDESTRIANS.MAX_WALKERS, self.walkers_spawn_cap + PEDESTRIANS.SPAWN_CAP_RAMP)
    self.walkers_spawn_interval_ms = math.max(PEDESTRIANS.MIN_SPAWN_INTERVAL_MS, self.walkers_spawn_interval_ms - PEDESTRIANS.SPAWN_INTERVAL_RAMP_MS)
  end

  self.walker_timer = timer.performAfterDelay(self.walkers_spawn_interval_ms, function() self:trySpawnWalker() end)
end

function GamePlay:spawnWalker()
  -- TODO: need better way to manage coordinate systems/origin point of legs
  local random_float = math.random()

  local walker_type_index = math.random(#PEDESTRIANS.TYPES)
  local walker_type = PEDESTRIANS.TYPES[walker_type_index]

  local direction = random_float >= 0.5 and DIRECTION.LEFT or DIRECTION.RIGHT

  local new_walker = Walker.spawn(walker_type, direction)
  table.insert(self.walkers, new_walker)
end

-- TODO: accessing this with a singleton/shread instance is gross
function GamePlay:updateScore(points)
  self.current_score += points
  self.hud:setScore(self.current_score)
end
