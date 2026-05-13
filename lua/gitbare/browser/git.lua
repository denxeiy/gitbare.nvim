local config = require("gitbare.config")

local M = {}

function M.bare_status()
    local lines = vim.fn.systemlist(
        "git -C " .. vim.fn.shellescape(config.options.dir) ..
        " --git-dir=" .. vim.fn.shellescape(config.options.git_dir) ..
        " --work-tree=" .. vim.fn.shellescape(config.options.work_tree) ..
        " status --porcelain"
    )

    local status = {}

    for _, line in ipairs(lines) do
        if line ~= "" then
            local code = line:sub(1, 2)
            local path = vim.trim(line:sub(3))
            status[path] = code
        end
    end

    return status
end

function M.bare_ls_files()
    return vim.fn.systemlist(
        "git -C " .. vim.fn.shellescape(config.options.dir) ..
        " --git-dir=" .. vim.fn.shellescape(config.options.git_dir) ..
        " --work-tree=" .. vim.fn.shellescape(config.options.work_tree) ..
        " ls-files"
    )
end

function M.clean(cmd)
    local old_git_dir   = vim.env.GIT_DIR
    local old_work_tree = vim.env.GIT_WORK_TREE

    vim.env.GIT_DIR = nil
    vim.env.GIT_WORK_TREE = nil

    local result = vim.fn.systemlist(cmd)

    vim.env.GIT_DIR       = old_git_dir
    vim.env.GIT_WORK_TREE = old_work_tree

    return result
end

function M.normal_root(path)
    local out = M.clean("git -C " .. vim.fn.shellescape(path) .. " rev-parse --show-toplevel")

    if not out or not out[1] then
        return nil
    end

    if out[1]:match("^fatal:") then
        return nil
    end

    if out[1] ~= "" then
        return out[1]
    end

    return nil
end

return M
