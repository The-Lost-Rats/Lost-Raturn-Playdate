import "CoreLibs/object"

import "scripts/player/states/PlayerState"

import "scripts/player/playerConstants"
import "utilities/constants"

local ANIMATION <const> = PLAYER_CONSTANTS.ANIMATION
local TAGS <const> = CONSTANTS.TAGS

---@class GroundedState: PlayerState
GroundedState = class('GroundedState').extends(PlayerState) or GroundedState

function GroundedState:readInput(player, a_pressed, b_pressed)
  if (a_pressed) then player:jump() end
  player.vx = player:horizontalMovement()
end

function GroundedState:resolveOverlap(player, other, tag)
  if (tag == TAGS.SHOE and other.controller:isFalling()) then
    player:hit(other.controller:getDamage())
  end
end

function GroundedState:animationName(player)
  return (player.vx == 0) and ANIMATION.IDLE or ANIMATION.RUN
end
