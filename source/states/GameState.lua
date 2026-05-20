import "CoreLibs/object"

class ('GameState').extends()
function GameState:enter() end
function GameState:leave() end
function GameState:update() error("update() not implemented in subclass!") end
