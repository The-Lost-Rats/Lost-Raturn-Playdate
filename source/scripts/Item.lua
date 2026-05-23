import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"

local gfx <const> = playdate.graphics

local image = gfx.image.new(8, 8, gfx.kColorBlack)

-- TODO: maybe change to map to functions? and do switch stmt like lookup
local ITEM_STATES = {
  FALLING = 0,
  GROUNDED = 1,
  DISAPPEARING = 2,
  PICKED_UP = 3
}

-- TODO: do we want the item to convert to a mini item when picked up? or do we want a distinct class?
class('Item').extends(gfx.sprite)
-- TODO: item type should really change to like sprite/image or something? or maybe keep and redo look up?
-- TODO: what else should this take in? x, y, vx, vy?
function Item:init(item_type)
  Item.super.init(self)
  self.vx, self.vy = 0, 0
  self:setImage(image)

  -- TODO: should this be passed in as inital state? ITEM STATES would need to be global/in constants
  self.current_state = nil
end

-- TODO: split into functions
function Item:update()
  local x, y = self:getPosition()

  if (self.current_state == ITEM_STATES.FALLING) then
    -- TODO: see if i can move some of this logic out to be shared
    self.vy = self.vy + CONSTANTS.GRAVITY * 0.60 -- TODO: magic number to fall slower
    y = y + self.vy
    x = x + self.vx

    if (y >= CONSTANTS.FLOOR_Y - self.height / 2) then
      self.vy = 0
      y = CONSTANTS.FLOOR_Y - self.height / 2
      self.current_state = ITEM_STATES.GROUNDED
    end

    self:moveTo(x, y)
  elseif(self.current_state == ITEM_STATES.GROUNDED) then
    -- TODO: sine wave moving
    local t = 1
  elseif (self.current_state == ITEM_STATES.DISAPPEARING) then
    local t = 1
    -- TODO: blink for 2s then remove self? what happens to ref in walker class?
  end
end

function Item:drop(x_pos, y_pos)
  self:moveTo(x_pos, y_pos)
  self.current_state = ITEM_STATES.FALLING
end
