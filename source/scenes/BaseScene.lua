import "CoreLibs/object"

---@class BaseScene
BaseScene = class ('BaseScene').extends() or BaseScene
function BaseScene:enter() end
function BaseScene:leave() end
function BaseScene:update() error("update() not implemented in subclass!") end
