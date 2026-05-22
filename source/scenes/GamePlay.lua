import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/timer"

import "scenes/BaseScene"
import "scripts/Player"
import "utilities/constants"

import "scripts/pedestrian/Walker"

local gfx <const> = playdate.graphics
local timer <const> = playdate.timer

class ('GamePlay').extends(BaseScene)
function GamePlay:init()
  GamePlay.super.init(self)
  self.player = Player(0, 0, 1, true)

  self.walkers = {}
  -- Start with a small number of walkers to let the player get used to the game.
  -- And longest spawn interval so they are created really slowly.
  -- Then ramp up slowly.
  self.walkers_spawn_cap = CONSTANTS.PEDESTRIANS.MIN_WALKERS, CONSTANTS.PEDESTRIANS
  self.walkers_spawn_interval_ms = CONSTANTS.PEDESTRIANS.MAX_SPAWN_INTERVAL_MS
end

function GamePlay:enter()
  self.player:reset()
  self.player:add()

  -- Start the walker spawning process
  self:trySpawnWalker()

  gfx.sprite.setBackgroundDrawingCallback(function(x, y, w, h)
    -- Redraw background elements and clip to dirty rect
    gfx.setColor(gfx.kColorBlack)

    local display_text = self.className
    local text_w, text_h = gfx.getTextSize(display_text)
    gfx.drawText(display_text, CONSTANTS.SCREEN_W_HALF - text_w / 2, CONSTANTS.SCREEN_H_HALF - text_h / 2)

    -- TODO: eventually create UI manager? Make this a sprite maybe?
    -- Floor line
    gfx.drawLine(0, CONSTANTS.FLOOR_Y, CONSTANTS.SCREEN_W, CONSTANTS.FLOOR_Y)

    -- HUD Box
    gfx.fillRect(0, 0, CONSTANTS.SCREEN_W, CONSTANTS.HUD_H)
    
    gfx.setColor(gfx.kColorWhite)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawText("Score: 0", 4, 4) -- TODO: make these constants or something

    -- TODO: these should not be hard coded - num hears should be here, loop, math to place
    gfx.fillCircleInRect(CONSTANTS.SCREEN_W - 20, 0, 10, CONSTANTS.HUD_H)
    gfx.fillCircleInRect(CONSTANTS.SCREEN_W - 40, 0, 10, CONSTANTS.HUD_H)
    gfx.fillCircleInRect(CONSTANTS.SCREEN_W - 60, 0, 10, CONSTANTS.HUD_H)
    
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    gfx.setColor(gfx.kColorBlack)
  end)
end

function GamePlay:update()
  for _, walker in ipairs(self.walkers) do
    walker:update()
  end

  -- Update sprites last to draw at new positions
  gfx.sprite.update()

  if (playdate.buttonJustPressed(playdate.kButtonA)) then
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
  if (#self.walkers < CONSTANTS.PEDESTRIANS.MAX_WALKERS) then
    self:spawnWalker()
    self.walkers_spawn_cap = math.min(CONSTANTS.PEDESTRIANS.MAX_WALKERS, self.walkers_spawn_cap + 0.5)
    self.walkers_spawn_interval_ms = math.max(CONSTANTS.PEDESTRIANS.MIN_SPAWN_INTERVAL_MS, self.walkers_spawn_interval_ms - 100) -- 100 should be tuneable
  end

  self.walker_timer = timer.performAfterDelay(self.walkers_spawn_interval_ms, function() self:trySpawnWalker() end)
end

function GamePlay:spawnWalker()
  local new_walker = Walker(CONSTANTS.PEDESTRIANS.COWBOY, CONSTANTS.SCREEN_W_HALF, CONSTANTS.FLOOR_Y)
  new_walker:add()

  table.insert(self.walkers, new_walker)
end
