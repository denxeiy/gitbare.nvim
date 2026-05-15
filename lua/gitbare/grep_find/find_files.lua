local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local config = require("gitbare.config")
local scanner = require("gitbare.grep_find.scanner")
local entry = require("gitbare.grep_find.entry_maker_grep_find")

local filter = require("gitbare.browser.filter")

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

    local function apply_filter(list)
        if not filter.state.filter then
            return list
        end

        local res = {}
        for _, item in ipairs(list) do
            if item.status and vim.trim(item.status) ~= "" then
                table.insert(res, item)
            end
        end
        return res
    end

    local function make_finder()
        local results = apply_filter(filtered)

        return finders.new_table({
            results = results,
            entry_maker = entry.path,
        })
    end

    pickers.new(opts, {
        prompt_title = "GitBare Find Files (" .. cwd .. ")",
        finder = make_finder(),
        previewer = conf.file_previewer(opts),
        sorter = conf.file_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            filter.attach_mappings(prompt_bufnr, map, make_finder)
            return true
        end,
    }):find()
end

return M
