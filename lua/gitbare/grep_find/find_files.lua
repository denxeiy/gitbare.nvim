local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values

local config = require("gitbare.config")
local scanner = require("gitbare.grep_find.scanner")
local entry = require("gitbare.grep_find.entry_maker_grep_find")

local M = {}

function M.find_files(opts)
  opts = opts or {}

  local gitdir = config.options.git_dir
  local workdir = config.options.dir
  local cwd = vim.fn.getcwd()
  local find_current = config.options.find_in_current_dir

  local all = scanner.scan_repo(workdir, gitdir)

  local filtered = {}

  if not find_current then
   filtered = all
  else
    for _, item in ipairs(all) do
      if vim.startswith(item.path, cwd .. "/") or item.path == cwd then
        table.insert(filtered, item)
      end
    end

    if #filtered == 0 then
      vim.notify("gitbare: no git dir here", vim.log.levels.WARN)
      return
    end
  end

  pickers.new(opts, {
    prompt_title = "GitBare Find Files (" .. cwd .. ")",
    finder = finders.new_table({
      results = filtered,
      entry_maker = entry.path,
    }),
    previewer = conf.file_previewer(opts),
    sorter = conf.file_sorter(opts),
  }):find()
end

return M
