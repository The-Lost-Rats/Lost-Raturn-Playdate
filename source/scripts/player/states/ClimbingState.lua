import "CoreLibs/object"

import "scripts/player/states/PlayerState"

import "scripts/player/playerConstants"
import "scripts/walker/walkerConstants"

import "utilities/math"

local ANIMATION <const> = PLAYER_CONSTANTS.ANIMATION
-- TODO: this seems wrong...
local CLIMBING <const> = WALKER_CONSTANTS.CLIMBING

local function getCrankClimbDelta()
  local _, accelerated_change = playdate.getCrankChange()
  local clamped = math.clamp(accelerated_change, -CLIMBING.MAX_ACCELERATED_CHANGE, CLIMBING.MAX_ACCELERATED_CHANGE)

  return -clamped * CLIMBING.PIXELS_PER_DEGREE
end

---@class ClimbingState: PlayerState
ClimbingState = class('ClimbingState').extends(PlayerState) or ClimbingState
function ClimbingState:init(leg)
  ClimbingState.super.init(self)

  self.leg = leg
  self.crank_dy = 0
end

function ClimbingState:enter(player)
  player.vx, player.vy = 0, 0
  self.prev_leg_x, self.prev_leg_y = self.leg:getPosition()
end

function ClimbingState:readInput(player, a_pressed, b_pressed)
  if (a_pressed) then player:jumpOffLeg() end
  self.crank_dy = getCrankClimbDelta()
end

function ClimbingState:applyForces(player)
  local leg_x, leg_y = self.leg:getPosition()

  player.vx = leg_x - self.prev_leg_x
  player.vy = (leg_y - self.prev_leg_y) + self.crank_dy

  self.prev_leg_x, self.prev_leg_y = leg_x, leg_y
end

function ClimbingState:constrain(player, x, y, hit_edge)
  y = math.clamp(y, self.leg:getClimbBounds())

  if (y <= self.leg:getScoreRange()) then
    player:scoreDelivery(self.leg)
  elseif (hit_edge) then
    player:jumpOffLeg()
  end

  return x, y
end

function ClimbingState:usesCrank() return true end

function ClimbingState:animationName(player)
  return ANIMATION.CLIMB
end
