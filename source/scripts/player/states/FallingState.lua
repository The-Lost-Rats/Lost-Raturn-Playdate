import "CoreLibs/object"

import "scripts/player/states/PlayerState"

import "scripts/player/playerConstants"
import "utilities/constants"

local ANIMATION <const> = PLAYER_CONSTANTS.ANIMATION
local PHYSICS <const> = CONSTANTS.PHYSICS
local WORLD <const> = CONSTANTS.WORLD
local TAGS <const> = CONSTANTS.TAGS

---@class FallingState: PlayerState
---@field private grab_requested boolean
---@overload fun(): FallingState
FallingState = class('FallingState').extends(PlayerState) or FallingState

function FallingState:readInput(player, a_pressed, b_pressed)
  player.vx = player:horizontalMovement()
  self.grab_requested = a_pressed
end

function FallingState:applyForces(player)
  player.vy += PHYSICS.GRAVITY
end

function FallingState:constrain(player, x, y, hit_edge)
  if (y >= WORLD.FLOOR_Y) then
    y = WORLD.FLOOR_Y
    player:land()
  end

  return x, y
end

---@param player Player
---@param other LegSprite
---@param tag integer
function FallingState:resolveOverlap(player, other, tag)
  if (self.grab_requested and tag == TAGS.LEG) then
    player:grabLeg(other)
  end
end

function FallingState:animationName(player)
  return ANIMATION.JUMP
end
