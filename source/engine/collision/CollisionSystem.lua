-- CollisionSystem.lua
-- Handles detecting and emiting signals on collisions (enter, exit).
--

import "CoreLibs/graphics"

import "engine/collision/Collider"

local gfx <const> = playdate.graphics

local previous_collisions = {}

--- Emit signals on collision enter
---@param collision_pair ColliderSprite[]
local function fireOnEnter(collision_pair)
  local sprite_1 = collision_pair[1]
  local sprite_2 = collision_pair[2]

  sprite_1.collider.enter_signal:emit(sprite_2.collider)
  sprite_2.collider.enter_signal:emit(sprite_1.collider)
end

--- Emit signals on collision exit
---@param collision_pair ColliderSprite[]
local function fireOnExit(collision_pair)
  local sprite_1 = collision_pair[1]
  local sprite_2 = collision_pair[2]

  sprite_1.collider.exit_signal:emit(sprite_2.collider)
  sprite_2.collider.exit_signal:emit(sprite_1.collider)
end

CollisionSystem = {}

function CollisionSystem.init() previous_collisions = {} end

function CollisionSystem.tick()
  local current_collisions = {}

  local collisions = gfx.sprite.allOverlappingSprites()
  for i = 1, #collisions do
    local collision_pair = collisions[i]
    local sprite_1 = collision_pair[1] --[[@as ColliderSprite]]
    local sprite_2 = collision_pair[2] --[[@as ColliderSprite]]

    if sprite_1.collider == nil or sprite_2.collider == nil then
      error("Error - CollisionSystem: One or both collision sprites are not type ColliderSprite", 2)
    end

    -- Compute unique key for collision
    local key_1 = math.min(sprite_1.collider.id, sprite_2.collider.id)
    local key_2 = math.max(sprite_1.collider.id, sprite_2.collider.id)
    local key = key_1 .. "|" .. key_2

    -- Store new collisions
    current_collisions[key] = { sprite_1, sprite_2 }
  end

  -- On Enter
  for key, pair in pairs(current_collisions) do
    if not previous_collisions[key] then fireOnEnter(pair) end
  end

  -- On Exit
  for key, pair in pairs(previous_collisions) do
    if not current_collisions[key] then fireOnExit(pair) end
  end

  -- Update previous collisions
  previous_collisions = current_collisions
end
