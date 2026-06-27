-- GroundedState.lua
-- Handles player moving on the ground (walk left and right, jump, take damage).
--

import "CoreLibs/object"

import "scripts/player/states/PlayerState"

import "scripts/player/playerConstants"
import "utilities/constants"

local ANIMATION <const> = PLAYER_CONSTANTS.ANIMATION
local TAGS <const> = CONSTANTS.TAGS

---@class GroundedState: PlayerState
---@overload fun(): GroundedState
GroundedState = class('GroundedState').extends(PlayerState) or GroundedState

function GroundedState:readInput(player, a_pressed, b_pressed)
  if (a_pressed) then player:jump() end
end

function GroundedState:applyForces(player, vx, vy)
  return player:horizontalMovement(), 0
end

---@param player Player
---@param other LegSprite|ShoeSprite
---@param tag integer
function GroundedState:resolveOverlap(player, other, tag)
  if (tag == TAGS.SHOE and other.controller:isFalling()) then
    player:hit(other.controller:getDamage())
  end
end

function GroundedState:animationName(player)
  return player:isMovingHorizontally() and ANIMATION.RUN or ANIMATION.IDLE
end
