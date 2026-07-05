-- PlayerState.lua
-- Base of the player state machine. Defaults are no-ops or passthroughs.
--

import "CoreLibs/object"

import "game/entities/player/playerConstants"

local ANIMATION <const> = PLAYER_CONSTANTS.ANIMATION

---@class PlayerState: _Object
PlayerState = class("PlayerState").extends() or PlayerState

--- Called once when this state becomes active (after a transition).
---@param player Player
function PlayerState:enter(player) end

--- Reads buttons. May trigger a state transition.
---@param player Player
---@param a_pressed boolean
---@param b_pressed boolean
function PlayerState:readInput(player, a_pressed, b_pressed) end

--- Computes this frame's velocity from the current velocity and returns it.
---@nodiscard
---@param player Player
---@param vx number
---@param vy number
---@return number
---@return number
function PlayerState:applyForces(player, vx, vy) return vx, vy end

--- Adjusts final player position (clamp to floor etc.) and then returns updated position.
---@nodiscard
---@param player Player
---@param x number
---@param y number
---@param hit_edge boolean
---@return number
---@return number
function PlayerState:constrain(player, x, y, hit_edge) return x, y end

--- Handle collisions for this state
---@param player Player
---@param other _Sprite
---@param tag integer
function PlayerState:resolveOverlap(player, other, tag) end

--- Is this state a final state in the finite state machine?
---@nodiscard
---@return boolean
function PlayerState:isTerminal() return false end

--- Does this state require use of the crank?
---@nodiscard
---@return boolean
function PlayerState:usesCrank() return false end

--- What is the Animation this state uses?
---@nodiscard
---@param player Player
---@return AnimationState
function PlayerState:animationName(player) return ANIMATION.IDLE end

--- Potential specific frame of current animation to show this tick.
--- Returns nil to let the animation loop continue on its own.
---@nodiscard
---@param player Player
---@param vy number
---@return integer?
function PlayerState:animationFrame(player, vy) return nil end
