import "CoreLibs/object"

import "scripts/player/states/PlayerState"

---@class DeadState: PlayerState
DeadState = class('DeadState').extends(PlayerState) or DeadState

function DeadState:enter(player)
  -- TODO: make badass dead animation
end

function DeadState:isTerminal() return true end
