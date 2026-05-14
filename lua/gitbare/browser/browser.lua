local config = require("gitbare.config")
local tree   = require("gitbare.browser.tree")
local node   = require("gitbare.browser.node")
local git    = require("gitbare.browser.git")
local finder = require("gitbare.browser.finder")

local M = {}

function M.setup_config_browse(opts)
    config.setup_browse(opts)
end

function M.gitbare_browser()
    local abs  = vim.fn.expand("%:p")
    local root = tree.build()

    if abs ~= "" and node.is_dotfile(abs, root) then
        local _, parent = node.find(abs, root)
        return finder.open(parent or root)
    end

    local file_dir = (abs ~= "")
        and vim.fn.fnamemodify(abs, ":h")
        or vim.loop.cwd()

    local git_root = git.normal_root(file_dir)

    if git_root then
        local ok = pcall(function()
            -- require("telescope.builtin").git_files({
            --     cwd            = git_root,
            --     show_untracked = false,
            -- })
            return finder.open(root)
        end)

        if not ok then
            vim.notify("Telescope: file is not defined in git repo", vim.log.levels.WARN)
        end

        return
    end

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

    vim.notify("File is not defined in git repo", vim.log.levels.WARN)
end

return M
