-- ClimbingState.lua
-- Handles player climbing a leg as well as dismount and scoring.
--

import "CoreLibs/object"

import "game/entities/player/states/PlayerState"

import "game/entities/player/playerConstants"

import "engine/math"

local ANIMATION <const> = PLAYER_CONSTANTS.ANIMATION
local CLIMBING <const> = PLAYER_CONSTANTS.CLIMBING

--- Get crank change (delta) and convert to player pixel movement.
---@nodiscard
---@return number
local function getCrankClimbDelta()
  local _, accelerated_change = playdate.getCrankChange()
  local clamped = math.clamp(
    accelerated_change,
    -CLIMBING.MAX_ACCELERATED_CHANGE,
    CLIMBING.MAX_ACCELERATED_CHANGE
  )

  return -clamped * CLIMBING.PIXELS_PER_DEGREE
end

---@class ClimbingState: PlayerState
---@field private leg Leg
---@field private crank_dy number
---@field private prev_leg_x number
---@field private prev_leg_y number
---@overload fun(leg: Leg): ClimbingState
ClimbingState = class("ClimbingState").extends(PlayerState) or ClimbingState
function ClimbingState:init(leg)
  ClimbingState.super.init(self)

  self.leg = leg
  self.crank_dy = 0
end

--- Snapshot the previous leg position so player can track leg delta and move
--- with the leg.
function ClimbingState:enter(player)
  self.prev_leg_x, self.prev_leg_y = self.leg:getPosition()
end

function ClimbingState:readInput(player, a_pressed, b_pressed)
  if a_pressed then player:jumpOffLeg() end
  self.crank_dy = getCrankClimbDelta()
end

--- Compute velocity based on leg movement.
--- Add crank delta to y velocity so player moves up or down the leg.
function ClimbingState:applyForces(player, vx, vy)
  local leg_x, leg_y = self.leg:getPosition()

  local new_vx = leg_x - self.prev_leg_x
  local new_vy = (leg_y - self.prev_leg_y) + self.crank_dy

  self.prev_leg_x, self.prev_leg_y = leg_x, leg_y

  return new_vx, new_vy
end

--- Constrain the player to the leg region when climbing.
--- If the player reaches score range - try and deliver an item.
--- If the player reaches the edge of the screen while on a leg - dismount.
function ClimbingState:constrain(player, x, y, hit_edge)
  y = math.clamp(y, self.leg:getClimbBounds())

  if y <= self.leg:getScoreThreshold() then
    player:scoreDelivery(self.leg)
  elseif hit_edge then
    player:jumpOffLeg()
  end

  return x, y
end

function ClimbingState:usesCrank() return true end

function ClimbingState:animationName(player) return ANIMATION.CLIMB end
