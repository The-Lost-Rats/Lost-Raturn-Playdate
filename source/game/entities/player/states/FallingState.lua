-- FallingState.lua
-- Handles player falling and grabbing a leg.
--

import "CoreLibs/object"

import "game/entities/player/states/PlayerState"

import "game/constants"

local PHYSICS <const> = CONSTANTS.PHYSICS
local WORLD <const> = CONSTANTS.WORLD
local TAGS <const> = CONSTANTS.TAGS

---@class FallingState: PlayerState
---@field private grab_requested boolean
---@overload fun(): FallingState
FallingState = class("FallingState").extends(PlayerState) or FallingState

function FallingState:readInput(player, a_pressed, b_pressed) self.grab_requested = a_pressed end

function FallingState:applyForces(player, vx, vy)
  return player:horizontalMovement(), vy + PHYSICS.GRAVITY
end

function FallingState:constrain(player, x, y, hit_edge)
  if y >= WORLD.FLOOR_Y then
    y = WORLD.FLOOR_Y
    player:land()
  end

  return x, y
end

---@param player Player
---@param other LegSprite
---@param tag integer
function FallingState:resolveOverlap(player, other, tag)
  if self.grab_requested and tag == TAGS.LEG then player:grabLeg(other) end
end
