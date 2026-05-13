local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local config = require("gitbare.config")

local M = {}

function M.live_grep(opts)
  opts = opts or {}

  local gitdir = config.options.git_dir
  local workdir = config.options.dir
  local grep_current = config.options.grep_in_current_dir
  local cwd = vim.fn.getcwd()

  if not gitdir or not workdir then
    vim.notify("gitbare: gitdir or dir not configured", vim.log.levels.ERROR)
    return
  end

  local function grep_cmd(prompt)
    if not prompt or prompt == "" then
      return nil
    end

    local args = {
      "git",
      "--git-dir=" .. gitdir,
    }

    if grep_current then
      table.insert(args, "--work-tree=" .. workdir)
    end

    table.insert(args, "grep")
    table.insert(args, "-n")
    table.insert(args, "--no-color")
    table.insert(args, "--full-name")
    table.insert(args, prompt)
    table.insert(args, "HEAD")

    return args
  end

  pickers.new(opts, {
    prompt_title = "GitBare Live Grep",
    finder = finders.new_job(grep_cmd, function(line)
      local tree, path, lnum, text = line:match("([^:]+):([^:]+):([^:]+):(.*)")
      if not path then
        return nil
      end

      local abs = workdir .. "/" .. path

      return {
        filename = abs,
        lnum = tonumber(lnum),
        text = text,
        display = path .. ":" .. lnum .. ": " .. text,
        ordinal = path .. " " .. text,
      }
    end),
    previewer = conf.grep_previewer(opts),
    sorter = conf.generic_sorter(opts),
  }):find()
end

return M
