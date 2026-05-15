local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local config = require("gitbare.config")

local scanner = require("gitbare.grep_find.scanner")
local filter = require("gitbare.browser.filter")
filter.load_state()

local M = {}

function M.live_grep(opts)
    opts = opts or {}

    if filter.state.filter == nil then
        filter.state.filter = false
    end

    local gitdir = config.options.git_dir
    local workdir = config.options.dir
    local grep_current = config.options.grep_in_current_dir

    if not scanner.last_status_map then
        scanner.scan_repo(workdir, gitdir)
    end

    if not gitdir or not workdir then
        vim.notify("gitbare: gitdir or dir not configured", vim.log.levels.ERROR)
        return
    end

    local status_map = scanner.last_status_map or {}

    local function allow_file(path)
        if not filter.state.filter then
            return true
        end

        local st = status_map[path]

        return st and vim.trim(st) ~= ""
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

    local function make_finder()
        return finders.new_job(grep_cmd, function(line)
            local tree, path, lnum, text = line:match("([^:]+):([^:]+):([^:]+):(.*)")
            if not path then
                return nil
            end

            if not allow_file(path) then
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
        end)
    end

    pickers.new(opts, {
        prompt_title = "GitBare Live Grep",
        finder = make_finder(),
        previewer = conf.grep_previewer(opts),
        sorter = conf.generic_sorter(opts),

        attach_mappings = function(prompt_bufnr, map)
            filter.attach_mappings(prompt_bufnr, map, make_finder)
            return true
        end,
    }):find()
end

return M
