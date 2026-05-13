local config = require("gitbare.config")
local tree   = require("gitbare.browser.tree")
local node   = require("gitbare.browser.node")
local git    = require("gitbare.browser.git")
local finder = require("gitbare.browser.finder")

local M = {}

-- Apply user configuration
function M.setup_config_browse(opts)
    config.setup_browse(opts)
end

-- Main entry point for gitbare file picker
function M.gitbare_browser()
    local abs  = vim.fn.expand("%:p")
    local root = tree.build()

    -- If current file is a dotfile inside the bare repo
    if abs ~= "" and node.is_dotfile(abs, root) then
        local _, parent = node.find(abs, root)
        return finder.open(parent or root)
    end

    -- Determine directory of current file or fallback to CWD
    local file_dir = (abs ~= "")
        and vim.fn.fnamemodify(abs, ":h")
        or vim.loop.cwd()

    -- Check if inside a normal git repo
    local git_root = git.normal_root(file_dir)

    if git_root then
        local ok = pcall(function()
            require("telescope.builtin").git_files({
                cwd            = git_root,
                show_untracked = false,
            })
        end)

        if not ok then
            vim.notify("Telescope: file is not defined in git repo", vim.log.levels.WARN)
        end

        return
    end

    -- If inside $HOME — use bare repo tree navigation
    if vim.startswith(file_dir, config.options.dir .. "/") or file_dir == config.options.dir then
        local nd, parent = node.find(file_dir, root)

        if nd then
            return finder.open(nd)
        elseif parent then
            return finder.open(parent)
        else
            return finder.open(root)
        end
    end

    -- Not a git repo and not inside bare repo
    vim.notify("File is not defined in git repo", vim.log.levels.WARN)
end

return M
