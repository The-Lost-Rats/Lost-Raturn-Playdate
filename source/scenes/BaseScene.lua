-- BaseScene.lua
-- Abstract scene base class. Subclasses override enter/leave/update.
-- Update must be implemented - default update throws error if not overriden.
--

import "CoreLibs/object"

---@class BaseScene: _Object
BaseScene = class ('BaseScene').extends() or BaseScene
function BaseScene:enter() end
function BaseScene:leave() end
function BaseScene:update() error("update() not implemented in subclass!") end
