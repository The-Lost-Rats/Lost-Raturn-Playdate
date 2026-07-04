-- FallingState.lua
-- Handles player falling and grabbing a leg.
--

import "CoreLibs/object"

import "scripts/player/states/PlayerState"

import "scripts/player/playerConstants"
import "utilities/constants"

local ANIMATION <const> = PLAYER_CONSTANTS.ANIMATION
local JUMP_FRAME <const> = PLAYER_CONSTANTS.JUMP_FRAME
local APEX_VY <const> = PLAYER_CONSTANTS.APEX_VY

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

function FallingState:animationName(player) return ANIMATION.JUMP end

--- Use player velocity to determine what frame of jump animation to show.
---@nodiscard
---@param player Player
---@param vy number
---@return integer?
function FallingState:animationFrame(player, vy)
  if vy < -APEX_VY then return JUMP_FRAME.RISE end
  if vy > APEX_VY then return JUMP_FRAME.FALL end
  return JUMP_FRAME.HANG
end
