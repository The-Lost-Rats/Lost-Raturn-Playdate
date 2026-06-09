import "CoreLibs/object"

import "scripts/player/states/PlayerState"
import "utilities/constants"

local TAGS <const> = CONSTANTS.TAGS

class('GroundedState').extends(PlayerState)

function GroundedState:readInput(player, a_pressed, b_pressed)
  if (a_pressed) then player:jump() end
  player.vx = player:horizontalMovement()
end

function GroundedState:resolveOverlap(player, other, tag)
  if (tag == TAGS.SHOE and other.controller:isFalling()) then
    player:hit(other.controller:getDamage())
  end
end
