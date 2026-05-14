local M = {}

M.options = {
  dir = nil,
  git_dir_name = nil,
  git_dir = nil,
  find_in_current_dir = false,
  grep_in_current_dir = false,
  work_tree = nil,
  filter_key = "<C-f>"
}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.options, opts or {})

  if M.options.dir and M.options.git_dir_name then
    M.options.git_dir = M.options.dir .. "/" .. M.options.git_dir_name
  end
end

function M.setup_browse(opts)
    M.options.dir      = opts.dir:gsub("/+$", "")
    M.options.git_dir   = M.options.dir .. "/" .. opts.git_dir_name
    M.options.work_tree = M.options.dir
end

return M
