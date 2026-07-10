-- Parameters.lua
-- Parameter delegate to ensure type safety when creating conditions for transitions
-- in AnimationController.
--

import "CoreLibs/object"

---@enum ParamType
PARAM_TYPE = {
  NUMBER = "number",
  BOOLEAN = "boolean",
  TRIGGER = "trigger",
}

---@class Parameters: _Object
---@field private declared table<string, ParamType>
---@field private values table<string, number | boolean>
---@field private trigger_names string[]
Parameters = class("Parameters").extends() or Parameters

--#region _____________________________  Init  _____________________________

function Parameters:init()
  Parameters.super.init(self)
  self.declared = {}
  self.values = {}
  self.trigger_names = {}
end
--#endregion

--#region _____________________________  Declare Parameters  _____________________________

---@param name string
---@param default? number defaults to 0
function Parameters:declareNumber(name, default)
  self.declared[name] = PARAM_TYPE.NUMBER
  self.values[name] = default or 0
end

---@param name string
---@param default? boolean defaults to false
function Parameters:declareBoolean(name, default)
  self.declared[name] = PARAM_TYPE.BOOLEAN
  self.values[name] = default or false
end

---@param name string
function Parameters:declareTrigger(name)
  self.declared[name] = PARAM_TYPE.TRIGGER
  self.values[name] = false
  table.insert(self.trigger_names, name)
end
--#endregion

--#region _____________________________  Set Parameters  _____________________________

---@param name string
---@param value number
function Parameters:setNumber(name, value)
  if self.declared[name] ~= PARAM_TYPE.NUMBER then
    error("Error - parameter " .. name .. " is not a number", 2)
  end

  self.values[name] = value
end

---@param name string
---@param value boolean
function Parameters:setBoolean(name, value)
  if self.declared[name] ~= PARAM_TYPE.BOOLEAN then
    error("Error - parameter " .. name .. " is not a boolean", 2)
  end

  self.values[name] = value
end

---@param name string
function Parameters:setTrigger(name)
  if self.declared[name] ~= PARAM_TYPE.TRIGGER then
    error("Error - parameter " .. name .. " is not a trigger", 2)
  end

  self.values[name] = true
end
--#endregion

--#region _____________________________  Query and Reset  _____________________________

---@param name string
---@return boolean | number
function Parameters:get(name) return self.values[name] end

function Parameters:resetTriggers()
  for _, name in ipairs(self.trigger_names) do
    self.values[name] = false
  end
end
--#endregion

--#region _____________________________  Validation  _____________________________

---@param name string
---@return boolean true if name is in declared
function Parameters:isDeclared(name) return self.declared[name] ~= nil end

---@param name string
---@return ParamType
function Parameters:typeOf(name) return self.declared[name] end
--#endregion
