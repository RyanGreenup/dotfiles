
-- Returns the current Notes directory
-- This is wrapped into a function as a form of config management
function Get_notes_dir()
  return Get_HOME() .. "/Notes/slipbox"
end
