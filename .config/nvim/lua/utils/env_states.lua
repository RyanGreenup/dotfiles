local M = {} -- define a table to hold our module

-- The State class provides an interface for managing and transitioning
-- between various states in a system. It's useful as a global variable
-- that can be set as a condition for plugins.
-- ## Example
-- Initialize the following object in global scope at the snippy setup
--
-- ```lua
-- Snippy_state = State.new({ "latex", "python" })
-- Snippy_state.is_state.latex -- false
-- Snippy_state:toggle(my_state.allowed_states.a)
-- Snippy_state.is_state.latex -- true
-- ```
--
-- Set a snippy expand condition based on `Snippy_state.is_state.latex`
-- and a keybinding to toggle that state and now snippy can have
-- single key stroke snippets at the users discretion.
--- @class State
State = {}
State.__index = State

--------------------------------------------------------------------------------
-- Constructor -----------------------------------------------------------------
--------------------------------------------------------------------------------

--- Initializes a state object
--- @param states table A list of valid states for the object to manage. Each element should be a unique string representing a possible state value.
--- @return State Returns an initialized state object, ready for use in managing states.
function State.new(states)
  local self = setmetatable({}, State) ---@class State
  self.state = nil
  self.allowed_states = {}
  -- use keys so they're exposed by autocomplete
  self.allowed_states = {}
  for _, s in pairs(states) do
    self.allowed_states[s] = s
  end
  -- Define a table of booleans so exposed by autocomplete
  self.is_state = {}
  self:update()
  return self
end

--------------------------------------------------------------------------------
-- Methods ---------------------------------------------------------------------
--------------------------------------------------------------------------------

--- Check if the current state matches the provided state.
---
--- If the current state is nil, this method will return false. Otherwise, it will compare the current state with the provided state and return true if they match, or false otherwise.
---
--- @param state_to_check string The state to check against the current state.
--- @return boolean Returns true if the current state matches the provided state, or false otherwise.
function State:check_state(state_to_check)
  if self.state == nil then
    return false
  else
    return self.state == state_to_check
  end
end

--- Updates the boolean representation of states in the object.
--- These are user facing to check the current state.
--- Attributes are preferred as they can be autocompleted.
---
--- This method iterates over all allowed states (defined during object creation)
--- and updates their corresponding boolean value in the `is_state` table to reflect
--- whether or not they are currently active according to the `check_state()` function.
function State:update()
  for _, s in pairs(self.allowed_states) do
    self.is_state[s] = self:check_state(s)
  end
end

--- Checks if the provided state is allowed. If not, prints a warning message listing all allowed states.
--- @param target_state string|nil The state to be checked. A nil value is considered valid and returns true.
--- @return boolean Returns true if the target state is allowed or if it's nil; false otherwise.
function State:state_is_allowed(target_state)
  -- nil value is permitted, it means default
  if target_state == nil then
    return true
  end

  local allowed_string = ""
  for _, v in pairs(self.allowed_states) do
    allowed_string = allowed_string .. "\n- " .. v
    if v == target_state then
      return true
    end
  end
  print("Warning: " .. target_state .. " is not an allowed state, must be one of:")
  print(allowed_string)
  return false
end

--- Sets the current state to the target state if it is a valid (allowed) state.
--- @param target_state any The desired new state for the object. It will be set as the current state if it is a valid option based on the `allowed_states` table.
function State:set(target_state)
  if self:state_is_allowed(target_state) then
    self.state = target_state
    self:update()
  end
end

--- Toggles the current state of an object between a target state and nil.
--- If the current state is nil, it sets the state to the target state; otherwise, it sets the state to nil.
--- @param target_state string The state that should be toggled on or off.
function State:toggle(target_state)
  if self.state == nil then
    self:set(target_state)
  else
    self:set(nil)
  end
end


-- Creates a new instance of the `State` class with the provided states.
--- @param states table A list of valid states for the object to manage.
--- @return State Returns an initialized state object.
function M.new(states)
    return State.new(states)
end

-- Returns a new Snippy_state object with predefined valid states.
--- @return State A newly created Snippy_state object with valid states set to "latex", "python", "rust", "markdown", "sympy", and "R".
function M.Snippy_state()
  return State.new({"latex", "python", "rust", "markdown", "sympy", "R"})
end

return M
