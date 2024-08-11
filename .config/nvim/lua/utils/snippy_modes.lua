








-- Create the table with setters and getters
My_Snippy_env = {}
function My_Snippy_env.set(key, value)
  My_Snippy_env[key] = value
end

function My_Snippy_env.get(key)
  return My_Snippy_env[key]
end

-- Define the available states
My_Snippy_env.states = {
  normal = "normal",
  latex = "latex",
}

function My_Snippy_env.get_state()
  return My_Snippy_env.state
end

My_Snippy_env.is_state = {}
function My_Snippy_env.is_state.update()
  for _, state in pairs(My_Snippy_env.states) do
    My_Snippy_env.is_state[state] = My_Snippy_env.get_state() == state
  end
end
My_Snippy_env.is_state.update()





--- Usage
---
---     My_globals.set_state(My_globals.states.normal)
function My_Snippy_env.set_state(new_state)
  My_Snippy_env.state = My_Snippy_env.states[new_state]
  My_Snippy_env.is_state.update()
end

function My_Snippy_env.reset_state()
  My_Snippy_env.set_state(My_Snippy_env.states.normal)
  print("Reverting to normal Mode")
end

-- Set the state to normal
My_Snippy_env.set_state("normal")

--- Toggle the given state from normal
---@param target_state string: the state to toggle to
function My_Snippy_env.toggle_state(target_state)
  if target_state == nil then
    -- Just revert to normal
    My_Snippy_env.reset_state()
  elseif target_state == My_Snippy_env.states.normal then
    print("Toggling normal is a no-op")
  else
    if My_Snippy_env.get_state() == target_state then
      -- Revert to normal
      My_Snippy_env.reset_state()
    else
      My_Snippy_env.set_state(target_state)
      print("Toggling to " .. target_state)
    end
  end
end
