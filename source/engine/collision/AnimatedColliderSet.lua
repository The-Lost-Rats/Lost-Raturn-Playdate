-- AnimatedColliderSet.lua
-- Collection of colliders that change on an animation.
--

import "CoreLibs/object"

import "engine/math"
import "engine/animation/Clip"
import "engine/collision/Collider"

---@class ColliderSpec
---@field groups? ColliderGroup[]
---@field collide_groups? ColliderGroup[]
---@field tag ColliderTag
---@field center [number, number] (x, y)

---@class AnimatedColliderSetConfig
---@field image _Image
---@field game_object _Object
---@field tag_map table<string, ColliderSpec>

---@class AnimatedColliderSet: _Object
---@field private colliders table<string, Collider>
---@overload fun(config: AnimatedColliderSetConfig): AnimatedColliderSet
AnimatedColliderSet = class("AnimatedColliderSet").extends() or AnimatedColliderSet

--- Initialize and validate colliders.
---@param config AnimatedColliderSetConfig
function AnimatedColliderSet:init(config)
  self.colliders = {}

  for tag_str, collider_spec in pairs(config.tag_map) do
    local collider = Collider({
      image = config.image,
      groups = collider_spec.groups,
      collide_groups = collider_spec.collide_groups,
      tag = collider_spec.tag,
      center = collider_spec.center,
      game_object = config.game_object,
    })

    self.colliders[tag_str] = collider
  end
end

--- Update colliders with current frame boxes.
--- Clear any that aren't active this frame.
---@param boxes FrameBoxes
function AnimatedColliderSet:applyBoxes(boxes)
  for tag, collider in pairs(self.colliders) do
    local rect = boxes[tag]
    if rect then
      collider:setRect(rect)
    else
      collider:clearRect()
    end
  end
end

--- Move and flip colliders to x and y with given flip mode.
---@param x number
---@param y number
---@param flip integer
function AnimatedColliderSet:follow(x, y, flip) end

--- Add all colliders to playdate sprite system.
function AnimatedColliderSet:add()
  for _, collider in pairs(self.colliders) do
    collider:add()
  end
end

--- Remove all colliders from playdate sprite system.
function AnimatedColliderSet:remove()
  for _, collider in pairs(self.colliders) do
    collider:remove()
  end
end

--- Get collider from tag string.
--- @param tag string
--- @return Collider
function AnimatedColliderSet:getCollider(tag)
  local collider = self.colliders[tag]
  if collider == nil then
    error("Error - AnimatedColliderSet: no collider found for tag " .. tag, 2)
  end

  return collider
end
