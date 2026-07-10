-- AnimationController
-- Animation state machine. Multiple states with clips and transitions between them.
--

import "CoreLibs/object"

import "engine/animation/Clip"
import "engine/animation/AnimationPlayer"

--#region _____________________________  Transitions  _____________________________

---@enum TransitionOp
TRANSITION_OP = {
  GREATER_THAN = "greater",
  LESS_THAN = "less",
  EQUAL_TO = "equal",
}

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
  if
    (operation == TRANSITION_OP.GREATER_THAN or operation == TRANSITION_OP.LESS_THAN)
    and type(value) == "boolean"
  then
    error(
      "Error - attempted to add a condition using operator " .. operation .. " for a boolean value",
      2
    )
  end

  table.insert(self.conditions, { name = name, operation = operation, value = value })
  return self
end

--- Are all the conditions for this transition true?
---@param values table<string, number | boolean>
---@param clip_complete boolean
---@return boolean
function Transition:isSatisfied(values, clip_complete)
  if self.wait_for_complete and not clip_complete then return false end

  for _, condition in ipairs(self.conditions) do
    local operation = condition.operation
    local value = values[condition.name]
    local compare = condition.value
    local condition_holds = false

    if operation == TRANSITION_OP.EQUAL_TO then
      condition_holds = value == compare
    elseif operation == TRANSITION_OP.GREATER_THAN then
      condition_holds = type(value) == "number" and value > compare
    elseif operation == TRANSITION_OP.LESS_THAN then
      condition_holds = type(value) == "number" and value < compare
    else
      error("Error - Unknown operation " .. operation .. " for " .. condition.name, 2)
    end

    if not condition_holds then return false end
  end

  return true
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
---@field private values table<string, number | boolean>
---@field private triggers table<string, true>
---@field private global_transitions Transition[] Any State Transition. Happens before current state's transitions.
---@overload fun(initial_state: AnimationState, global_transitions?: Transition[]): AnimationController
AnimationController = class("AnimationController").extends() or AnimationController

---@param initial_state AnimationState
---@param global_transitions? Transition[]
function AnimationController:init(initial_state, global_transitions)
  AnimationController.super.init(self)

  self.animation_player = AnimationPlayer(initial_state.clip)
  self.current_state = initial_state
  self.global_transitions = global_transitions or {}
  self.values = {}
  self.triggers = {}
end

---@param name string
---@param value boolean
function AnimationController:setBool(name, value) self.values[name] = value end

---@param name string
---@param value number
function AnimationController:setNumber(name, value) self.values[name] = value end

---@param name string
function AnimationController:setTrigger(name)
  self.values[name] = true
  self.triggers[name] = true
end

--- First transition in list whose conditions are all true; else nil.
---@private
---@param transitions Transition[]
---@return Transition?
function AnimationController:_findFirstValidTransition(transitions)
  local clip_complete = self.animation_player:isComplete()
  for _, transition in ipairs(transitions) do
    if transition:isSatisfied(self.values, clip_complete) then return transition end
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
  for name in pairs(self.triggers) do
    self.values[name] = false
  end
  self.triggers = {}

  return self.animation_player:update(dt)
end

--- Subscribe to the active clip's frame events.
---@param listener fun(event_name: string)
---@return integer handle
function AnimationController:onEvent(listener) return self.animation_player:onEvent(listener) end

---@return _Image
function AnimationController:getImage() return self.animation_player:getImage() end
--#endregion
