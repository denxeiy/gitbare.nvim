local make_entry = require("telescope.make_entry")

local M = {}

function M.path(entry)
  return make_entry.gen_from_file({})(entry.path)
end

return M
