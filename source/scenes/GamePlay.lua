import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/timer"
import "CoreLibs/ui"

import "scenes/BaseScene"
import "scripts/pedestrian/Walker"
import "scripts/Player"
import "utilities/constants"

local gfx <const> = playdate.graphics
local timer <const> = playdate.timer
local ui <const> = playdate.ui

-- TODO: should we have itemsbe tracked here? so i can remove items if they are lingering on game over or something?
class ('GamePlay').extends(BaseScene)
function GamePlay:init()
  -- TODO: should i set center of sprites to like bottom center?
  GamePlay.super.init(self)
  self.player = Player(0, 0, 1, CONSTANTS.PLAYER.MAX_HEALTH, self)

  self.walkers = {}
  -- Start with a small number of walkers to let the player get used to the game.
  -- And longest spawn interval so they are created really slowly.
  -- Then ramp up slowly.
  self.walkers_spawn_cap = CONSTANTS.PEDESTRIANS.MIN_WALKERS
  self.walkers_spawn_interval_ms = CONSTANTS.PEDESTRIANS.MAX_SPAWN_INTERVAL_MS
end

function GamePlay:enter()
  self.player:reset()
  self.player:add()
  self.current_score = 0

  -- Start the walker spawning process
  self:trySpawnWalker()

  gfx.sprite.setBackgroundDrawingCallback(function(x, y, w, h)
    -- Redraw background elements and clip to dirty rect
    gfx.pushContext()

    gfx.setColor(gfx.kColorBlack)

    local display_text = self.className
    local text_w, text_h = gfx.getTextSize(display_text)
    gfx.drawText(display_text, CONSTANTS.DISPLAY.W_HALF - text_w / 2, CONSTANTS.DISPLAY.H_HALF - text_h / 2)

    -- TODO: eventually create UI manager? Make this a sprite maybe?
    -- Floor line
    gfx.drawLine(0, CONSTANTS.WORLD.FLOOR_Y, CONSTANTS.DISPLAY.W, CONSTANTS.WORLD.FLOOR_Y)

    -- HUD Box
    gfx.fillRect(0, 0, CONSTANTS.DISPLAY.W, CONSTANTS.HUD.H)
    
    gfx.setColor(gfx.kColorWhite)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawText("Score: " .. self.current_score, CONSTANTS.HUD.SCORE_X, CONSTANTS.HUD.SCORE_Y)

    local player_health = self.player:getCurrentHealth()
    for i = 1, CONSTANTS.PLAYER.MAX_HEALTH, 1 do
      local x = CONSTANTS.DISPLAY.W - CONSTANTS.HUD.HEART_SPACING * i
      if (i <= player_health) then
        gfx.fillCircleInRect(x, 0, CONSTANTS.HUD.HEART_RADIUS, CONSTANTS.HUD.H)
      else
        gfx.drawCircleInRect(x, 0, CONSTANTS.HUD.HEART_RADIUS, CONSTANTS.HUD.H)
      end
    end
    
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
end

function GamePlay:trySpawnWalker()
  if (#self.walkers < self.walkers_spawn_cap) then
    self:spawnWalker()
    self.walkers_spawn_cap = math.min(CONSTANTS.PEDESTRIANS.MAX_WALKERS, self.walkers_spawn_cap + CONSTANTS.PEDESTRIANS.SPAWN_CAP_RAMP)
    self.walkers_spawn_interval_ms = math.max(CONSTANTS.PEDESTRIANS.MIN_SPAWN_INTERVAL_MS, self.walkers_spawn_interval_ms - CONSTANTS.PEDESTRIANS.SPAWN_INTERVAL_RAMP_MS)
  end

  self.walker_timer = timer.performAfterDelay(self.walkers_spawn_interval_ms, function() self:trySpawnWalker() end)
end

function GamePlay:spawnWalker()
  -- TODO: need better way to manage coordinate systems/origin point of legs
  local random_float = math.random()
  local new_walker

  local walker_type_index = math.random(#CONSTANTS.PEDESTRIANS.TYPES)
  local walker_type = CONSTANTS.PEDESTRIANS.TYPES[walker_type_index]

  -- TODO: clean this up so i don't make the whole arg list twice
  -- TODO: why shift by shoe height / 2 -> can i move this to the walker itself? or change sprite anchors
  -- TODO: do all these need to be constants? it looks a little ugly
  if (random_float >= 0.5) then
    new_walker = Walker(walker_type, CONSTANTS.PEDESTRIANS.SPAWN_POSITION_RIGHT, CONSTANTS.WORLD.FLOOR_Y - CONSTANTS.PEDESTRIANS.SHOE_H / 2, CONSTANTS.PEDESTRIANS.LEFT_VX, CONSTANTS.PEDESTRIANS.VY, CONSTANTS.DIRECTION.LEFT)
  else
    new_walker = Walker(walker_type, CONSTANTS.PEDESTRIANS.SPAWN_POSITION_LEFT, CONSTANTS.WORLD.FLOOR_Y - CONSTANTS.PEDESTRIANS.SHOE_H / 2, CONSTANTS.PEDESTRIANS.RIGHT_VX, CONSTANTS.PEDESTRIANS.VY, CONSTANTS.DIRECTION.RIGHT)
  end
  
  new_walker:add()
  table.insert(self.walkers, new_walker)
end

-- TODO: accessing this with a singleton/shread instance is gross
-- TODO: make this a sprite too? put in UI manager class?
function GamePlay:updateScore(points)
  self.current_score += points
  gfx.sprite.addDirtyRect(0, 0, CONSTANTS.DISPLAY.W, CONSTANTS.HUD.H)
end
