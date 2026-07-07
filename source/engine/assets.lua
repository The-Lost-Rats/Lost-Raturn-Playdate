-- assets.lua
-- Module used to load images and image tables.
-- Stores data in caches so we only load once.
-- Fails loud if assets do not exist.
--

import "CoreLibs/graphics"

local gfx <const> = playdate.graphics

local image_cache = {}
local image_table_cache = {}

Assets = {}

--#region _____________________________  Locals  _____________________________

--- Builds error message for when asset loading fails.
---@param kind string
---@param path string
---@param context? string
---@param err? string
---@return string
local function buildErrorMessage(kind, path, context, err)
  local msg = "Error - could not load " .. kind .. " at " .. path
  if context then msg = msg .. " for " .. context end
  if err then msg = msg .. " (" .. err .. ")" end

  return msg
end
--#endregion

--#region _____________________________  Asset Loading  _____________________________

---@param path string
---@param context? string What is this image for?
---@return _Image
function Assets.loadImage(path, context)
  local image = image_cache[path]
  if image == nil then
    local loaded_image, err = gfx.image.new(path)
    if loaded_image == nil then error(buildErrorMessage("image", path, context, err), 2) end

    image = loaded_image
    image_cache[path] = image
  end

  return image
end

---@param path string
---@param context? string What is this image table for?
---@return _ImageTable
function Assets.loadImageTable(path, context)
  local image_table = image_table_cache[path]
  if image_table == nil then
    local loaded_image_table, err = gfx.imagetable.new(path)
    if loaded_image_table == nil then
      error(buildErrorMessage("image table", path, context, err), 2)
    end

    image_table = loaded_image_table
    image_table_cache[path] = image_table
  end

  return image_table
end
--#endregion
