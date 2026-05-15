local config = require("gitbare.config")
local ff = require("gitbare.grep_find.find_files")
local lg = require("gitbare.grep_find.live_grep")

local M = {}

function M.setup(opts)
    require("gitbare.browser.browser").setup_config_browse(opts)
    config.setup(opts)

    local builtin = require("telescope.builtin")
    builtin.gitbare_find_files = ff.find_files
    builtin.gitbare_live_grep = lg.live_grep
-----------------commands--------------------
    local cmds = require("gitbare.commands")
    for name, fn in pairs(cmds) do
        vim.api.nvim_create_user_command(name, fn, {})
    end
---------------------------------------------
end

M.gitbare_browser = require("gitbare.browser.browser").gitbare_browser

return M
