-- AnimationStateMachine (AnimationController?)
--

import "CoreLibs/object"

import "engine/animation/Clip"
import "engine/animation/AnimationPlayer"

---@enum TransitionCondition
TRANSITION_CONDITION = {
  GREATER_THAN = "great_than",
  LESS_THAN = "less_than",
  EQUAL_TO = "equal_to",
  IS_TRUE = "is_true",
  IS_FALSE = "is_false",
}

---@enum IntegerCondition
TRANSITION_INTEGER_CONDITION = {
  TRANSITION_CONDITION.EQUAL_TO,
  TRANSITION_CONDITION.GREATER_THAN,
  TRANSITION_CONDITION.LESS_THAN,
}

---@enum NumberCondition
TRANSITION_NUMBER_CONDITION = {
  TRANSITION_CONDITION.GREATER_THAN,
  TRANSITION_CONDITION.LESS_THAN,
}

---@enum BooleanCondition
TRANSITION_BOOLEAN_CONDITION = {
  TRANSITION_CONDITION.EQUAL_TO,
}

---@enum BooleanUnaryCondition
TRANSITION_BOOLEAN_UNARY_CONDITION = {
  TRANSITION_CONDITION.IS_TRUE,
  TRANSITION_CONDITION.IS_FALSE,
}

---@class Condition
---@field name string
---@field operation TransitionCondition
---@field value? integer | number | boolean

---@class Transition: _Object
---@field conditions Condition[]
---@field has_exit_time boolean
---@field to_state AnimationState
Transition = class("Transition").extends() or Transition

---@param to_state AnimationState
---@param has_exit_time boolean
function Transition:init(to_state, has_exit_time)
  Transition.super.init(self)
  self.conditions = {}
  self.to_state = to_state
  self.has_exit_time = has_exit_time
end

---@param name string
---@param operation IntegerCondition
---@param value integer
function Transition:addIntegerCondition(name, operation, value)
  table.insert(self.conditions, { name = name, operation = operation, value = value })
end

---@param name string
---@param operation NumberCondition
---@param value number
function Transition:addNumberCondition(name, operation, value)
  table.insert(self.conditions, { name = name, operation = operation, value = value })
end

---@param name string
---@param operation BooleanCondition
---@param value boolean
function Transition:addBooleanCondition(name, operation, value)
  table.insert(self.conditions, { name = name, operation = operation, value = value })
end

---@param name string
---@param operation BooleanUnaryCondition
function Transition:addUnaryBooleanCondition(name, operation)
  table.insert(self.conditions, { name = name, operation = operation })
end

---@param values table<string, integer|number|boolean>
---@return boolean
function Transition:isTrue(values)
  local conditions_hold = true
  for _, condition in pairs(self.conditions) do
    local operation = condition.operation
    local is_true = false

    if operation == TRANSITION_CONDITION.EQUAL_TO then
      is_true = values[condition.name] == condition.value
    elseif operation == TRANSITION_CONDITION.GREATER_THAN then
      is_true = values[condition.name] > condition.value
    elseif operation == TRANSITION_CONDITION.LESS_THAN then
      is_true = values[condition.name] < condition.value
    elseif operation == TRANSITION_CONDITION.IS_TRUE then
      is_true = values[condition.name] == true
    elseif operation == TRANSITION_CONDITION.IS_FALSE then
      is_true = values[condition.name] == false
    else
      error("Error - Unknown operation " .. operation .. " for " .. condition.name, 2)
    end

    conditions_hold = conditions_hold and is_true

    if conditions_hold == false then return false end
  end

  return true
end

---@class AnimationState
---@field clip Clip
---@field transitions Transition[]

---@class AnimationController: _Object
---@field animation_player AnimationPlayer
---@field current_state AnimationState
---@field states AnimationState[]
---@field values table<string, integer | number | boolean>
---@field triggers string[]
---@field global_transitions Transition[]
AnimationController = class("AnimationController").extends() or AnimationController

---@param initial_state AnimationState
---@param states AnimationState[]
---@param global_transitions Transition[]
function AnimationController:init(initial_state, states, global_transitions)
  AnimationController.super.init(self)

  self.animation_player = AnimationPlayer(initial_state.clip)
  self.current_state = initial_state
  self.states = states
  self.global_transitions = global_transitions or {}

  self.values = {}
  self.triggers = {}
end

---@param name string
---@param value boolean
function AnimationController:setBool(name, value) self.values[name] = value end

---@param name string
---@param value integer
function AnimationController:setInteger(name, value) self.values[name] = value end

---@param name string
---@param value number
function AnimationController:setNumber(name, value) self.values[name] = value end

---@param name string
function AnimationController:setTrigger(name)
  self.values[name] = true
  table.insert(self.triggers, name)
end

function AnimationController:update(dt)
  -- Evaluate global transitions before current state transitions
  -- TODO: this can be better... evaluate global -> if false evaluate current state?
  local combined_transitions = {}
  for _, v in ipairs(self.global_transitions) do
    table.insert(combined_transitions, v)
  end
  for _, v in ipairs(self.current_state.transitions) do
    table.insert(combined_transitions, v)
  end

  for _, transition in ipairs(combined_transitions) do
    if
      (not transition.has_exit_time or self.animation_player:isComplete())
      and transition:isTrue(self.values)
    then
      self.current_state = transition.to_state
      self.animation_player:play(self.current_state.clip)
      break
    end
  end

  -- Reset triggers
  for _, name in pairs(self.triggers) do
    self.values[name] = false
  end
  self.triggers = {}

  return self.animation_player:update(dt)
end

function AnimationController:getImage() return self.animation_player:getImage() end
