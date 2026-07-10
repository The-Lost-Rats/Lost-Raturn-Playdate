-- Signal.lua
-- Synchronous observer. An owner creates a signal; consumers subscribe.
-- emit() fans out to every subscriber in subscription order and returns nothing.
--

import "CoreLibs/object"

---@class Subscriber<T>
---@field handle integer
---@field listener fun(payload: T)

---@class Signal<T>: _Object
---@field private subscribers Subscriber<`T`>[]
---@field private next_handle integer
---@overload fun(): Signal
Signal = class("Signal").extends() or Signal

function Signal:init()
  Signal.super.init(self)
  self.subscribers = {}
  self.next_handle = 1
end

--- Registers a listener that is invoked on every emit by this signal
--- until unsubscribed.
---@param listener fun(payload: T)
---@return integer handle signal handle/id to unsubscribe with
function Signal:subscribe(listener)
  local handle = self.next_handle
  self.next_handle += 1

  ---@type Subscriber
  local subscriber = { handle = handle, listener = listener }

  table.insert(self.subscribers, subscriber)
  return handle
end

---@param handle integer
function Signal:unsubscribe(handle)
  for i = 1, #self.subscribers do
    if self.subscribers[i].handle == handle then
      table.remove(self.subscribers, i)
      return
    end
  end
end

--- Invoke every subscriber with payload, in subscription order.
--- Synchronous.
---@param payload T
function Signal:emit(payload)
  --- Snapshot listeners in case an unsubscribe comes in during an emit.
  local listeners = {}
  for i = 1, #self.subscribers do
    listeners[i] = self.subscribers[i].listener
  end
  for i = 1, #listeners do
    listeners[i](payload)
  end
end
