import "CoreLibs/object"

import "scripts/player/playerConstants"

local ANIMATION <const> = PLAYER_CONSTANTS.ANIMATION

class('PlayerState').extends()

function PlayerState:enter(player) end

function PlayerState:readInput(player, a_pressed, b_pressed) end

function PlayerState:applyForces(player) end

function PlayerState:constrain(player, x, y, hit_edge)
  return x, y
end

function PlayerState:resolveOverlap(player, other, tag) end

function PlayerState:isTerminal() return false end

function PlayerState:usesCrank() return false end

function PlayerState:animationName(player) return ANIMATION.IDLE end
