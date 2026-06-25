import "CoreLibs/object"

local SCORING <const> = {
    CORRECT_DELIVERY = 100,
    WRONG_DELIVERY = -50
}

---@class ScoreManager
ScoreManager = class('ScoreManager').extends() or ScoreManager
function ScoreManager:init()
  self:reset()
end

function ScoreManager:reset()
  self.total = 0
  self.streak = 0
end

function ScoreManager:recordDelivery(item_type, leg_type)
  local correct_delivery = item_type == leg_type

  local points
  if (correct_delivery) then
    self.streak += 1
    points = SCORING.CORRECT_DELIVERY
  else
    self.streak = 0
    points = SCORING.WRONG_DELIVERY
  end

  self.total = math.max(0, self.total + points)

  return { correct = correct_delivery, points = points, total = self.total, streak = self.streak }
end

function ScoreManager:getScore()
  return self.total
end
