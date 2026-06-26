import "CoreLibs/object"

import "scripts/player/playerConstants"

local ANIMATION <const> = PLAYER_CONSTANTS.ANIMATION

---@class PlayerState: _Object
PlayerState = class('PlayerState').extends() or PlayerState

---@param player Player
function PlayerState:enter(player) end

---@param player Player
---@param a_pressed boolean
---@param b_pressed boolean
function PlayerState:readInput(player, a_pressed, b_pressed) end

---@param player Player
function PlayerState:applyForces(player) end

---@nodiscard
---@param player Player
---@param x number
---@param y number
---@param hit_edge boolean
---@return number
---@return number
function PlayerState:constrain(player, x, y, hit_edge)
  return x, y
end

---@param player Player
---@param other _Sprite
---@param tag integer
function PlayerState:resolveOverlap(player, other, tag) end

---@nodiscard
---@return boolean
function PlayerState:isTerminal() return false end

---@nodiscard
---@return boolean
function PlayerState:usesCrank() return false end

---@nodiscard
---@param player Player
---@return AnimationState
function PlayerState:animationName(player) return ANIMATION.IDLE end
