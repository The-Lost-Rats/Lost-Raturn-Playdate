-- DeadState.lua
-- Currently final state that pushes game to game over scene.
--

import "CoreLibs/object"

import "game/entities/player/states/PlayerState"

---@class DeadState: PlayerState
---@overload fun(): DeadState
DeadState = class("DeadState").extends(PlayerState) or DeadState

function DeadState:enter(player)
  -- TODO: make badass dead animation
end

function DeadState:isTerminal() return true end
