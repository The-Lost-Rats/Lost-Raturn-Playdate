import "CoreLibs/object"

import "scripts/player/states/PlayerState"

class('DeadState').extends(PlayerState)

function DeadState:enter(player)
  -- TODO: make badass dead animation
end

function DeadState:isTerminal() return true end
