import "CoreLibs/object"

class ('BaseScene').extends()
function BaseScene:enter() end
function BaseScene:leave() end
function BaseScene:update() error("update() not implemented in subclass!") end
