-- AnimationController
-- Animation state machine. Multiple states with clips and transitions between them.
--

import "CoreLibs/object"

import "engine/animation/Clip"
import "engine/animation/AnimationPlayer"
import "engine/animation/Parameters"

--#region _____________________________  Transitions  _____________________________

---@enum TransitionOp
TRANSITION_OP = {
  GREATER_THAN = "greater",
  LESS_THAN = "less",
  EQUAL_TO = "equal",
}

---@param operation TransitionOp
local function isComparison(operation)
  return operation == TRANSITION_OP.GREATER_THAN or operation == TRANSITION_OP.LESS_THAN
end

---@class Condition
---@field name string
---@field operation TransitionOp
---@field value number | boolean

---@class Transition: _Object
---@field private conditions Condition[]
---@field private wait_for_complete boolean require the current clip to finish before transition
---@field to_state AnimationState
---@overload fun(to_state: AnimationState, wait_for_complete?: boolean): Transition
Transition = class("Transition").extends() or Transition

---@param to_state AnimationState
---@param wait_for_complete? boolean defaults to false
function Transition:init(to_state, wait_for_complete)
  Transition.super.init(self)
  self.conditions = {}
  self.to_state = to_state
  self.wait_for_complete = wait_for_complete or false
end

---@param name string
---@param operation TransitionOp
---@param value number | boolean
---@return Transition self to allow chaining conditions
function Transition:addCondition(name, operation, value)
  if isComparison(operation) and type(value) == "boolean" then
    error(
      "Error - attempted to add a condition using operator " .. operation .. " for a boolean value",
      2
    )
  end

  table.insert(self.conditions, { name = name, operation = operation, value = value })
  return self
end

--- Are all the conditions for this transition true?
---@param parameters Parameters
---@param clip_complete boolean
---@return boolean
function Transition:isSatisfied(parameters, clip_complete)
  if self.wait_for_complete and not clip_complete then return false end

  for _, condition in ipairs(self.conditions) do
    local operation = condition.operation
    local value = parameters:get(condition.name)
    local compare = condition.value
    local condition_holds = false

    if operation == TRANSITION_OP.EQUAL_TO then
      condition_holds = value == compare
    elseif operation == TRANSITION_OP.GREATER_THAN then
      condition_holds = value > compare
    elseif operation == TRANSITION_OP.LESS_THAN then
      condition_holds = value < compare
    else
      error("Error - Unknown operation " .. operation .. " for " .. condition.name, 2)
    end

    if not condition_holds then return false end
  end

  return true
end

---@param parameter_type ParamType
---@param operation TransitionOp
local function validOperation(parameter_type, operation)
  if isComparison(operation) then return parameter_type == PARAM_TYPE.NUMBER end
  return true
end

--- Checks transition conditions are valid. Throws error if not.
---@param parameters Parameters
function Transition:validate(parameters)
  for _, condition in ipairs(self.conditions) do
    local name = condition.name
    if not parameters:isDeclared(name) then
      error("Error - transition uses non-existent value " .. name, 2)
    end

    local parameter_type = parameters:typeOf(name)
    local operation = condition.operation
    if not validOperation(parameter_type, operation) then
      error(
        "Error - transition uses invalid operation "
          .. operation
          .. " for condition of type "
          .. parameter_type,
        2
      )
    end
  end
end
--#endregion

--#region _____________________________  Animation State  _____________________________

---@class AnimationState: _Object
---@field clip Clip
---@field transitions Transition[]
---@overload fun(clip: Clip, transitions?: Transition[]): AnimationState
AnimationState = class("AnimationState").extends() or AnimationState

---@param clip Clip
---@param transitions? Transition[] defaults to none
function AnimationState:init(clip, transitions)
  AnimationState.super.init(self)
  self.clip = clip
  self.transitions = transitions or {}
end
--#endregion

--#region _____________________________  Animation Controller  _____________________________

---@class AnimationController: _Object
---@field private animation_player AnimationPlayer
---@field private current_state AnimationState
---@field private parameters Parameters
---@field private global_transitions Transition[] Any State Transition. Happens before current state's transitions.
---@overload fun(initial_state: AnimationState, parameters: Parameters, global_transitions?: Transition[]): AnimationController
AnimationController = class("AnimationController").extends() or AnimationController

---@param initial_state AnimationState
---@param parameters Parameters
---@param global_transitions? Transition[]
function AnimationController:init(initial_state, parameters, global_transitions)
  AnimationController.super.init(self)

  self.animation_player = AnimationPlayer(initial_state.clip)
  self.current_state = initial_state
  self.parameters = parameters
  self.global_transitions = global_transitions or {}

  -- Validate transition conditions on start up
  self:_validateStateGraph()
end

---@private
function AnimationController:_validateStateGraph()
  local to_visit = { self.current_state }
  for _, transition in ipairs(self.global_transitions) do
    transition:validate(self.parameters)
    table.insert(to_visit, transition.to_state)
  end

  local visited = {}
  while #to_visit > 0 do
    local state = table.remove(to_visit)
    if not visited[state] then
      visited[state] = true

      for _, transition in ipairs(state.transitions) do
        transition:validate(self.parameters)
        table.insert(to_visit, transition.to_state)
      end
    end
  end
end

---@param name string
---@param value boolean
function AnimationController:setBoolean(name, value) self.parameters:setBoolean(name, value) end

---@param name string
---@param value number
function AnimationController:setNumber(name, value) self.parameters:setNumber(name, value) end

---@param name string
function AnimationController:setTrigger(name) self.parameters:setTrigger(name) end

--- First transition in list whose conditions are all true; else nil.
---@private
---@param transitions Transition[]
---@return Transition?
function AnimationController:_findFirstValidTransition(transitions)
  local clip_complete = self.animation_player:isComplete()
  for _, transition in ipairs(transitions) do
    if transition:isSatisfied(self.parameters, clip_complete) then return transition end
  end

  return nil
end

--- Return true if the drawn frame changed.
---@param dt number (ms)
---@return boolean
function AnimationController:update(dt)
  -- Evaluate global transitions before current state transitions
  local fired = self:_findFirstValidTransition(self.global_transitions)
    or self:_findFirstValidTransition(self.current_state.transitions)
  if fired then
    self.current_state = fired.to_state
    self.animation_player:play(self.current_state.clip)
  end

  -- Reset triggers
  self.parameters:resetTriggers()

  return self.animation_player:update(dt)
end

--- Subscribe to the active clip's frame events.
---@param listener fun(event_name: string)
---@return integer handle
function AnimationController:onEvent(listener) return self.animation_player:onEvent(listener) end

---@return _Image
function AnimationController:getImage() return self.animation_player:getImage() end

---@return FrameBox[]
function AnimationController:getFrameBoxes() return self.animation_player:getFrameBoxes() end
--#endregion
