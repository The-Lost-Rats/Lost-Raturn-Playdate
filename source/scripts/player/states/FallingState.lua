import "CoreLibs/object"

import "scripts/player/states/PlayerState"
import "utilities/constants"

local PHYSICS <const> = CONSTANTS.PHYSICS
local WORLD <const> = CONSTANTS.WORLD
local TAGS <const> = CONSTANTS.TAGS

class('FallingState').extends(PlayerState)

function FallingState:readInput(player, a_pressed, b_pressed)
  player.vx = player:horizontalMovement()
  player.grab_requested = a_pressed
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

function FallingState:resolveOverlap(player, other, tag)
  if (player.grab_requested and tag == TAGS.LEG) then
    player:grabLeg(other)
  end
end
