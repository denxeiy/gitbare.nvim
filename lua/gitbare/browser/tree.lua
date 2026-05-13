local config = require("gitbare.config")
local git    = require("gitbare.browser.git")

local M = {}

local function build_tree()
    local rel_files  = git.bare_ls_files()
    local git_status = git.bare_status()

    local root = {
        name       = "",
        children   = {},
        is_file    = false,
        abs        = nil,
        parent     = nil,
        size       = 0,
        mtime      = 0,
        git_status = "  ",
    }

    local function insert_abs(abs)
        local rel   = abs:sub(#config.options.dir + 2)
        local parts = vim.split(rel, "/", { plain = true, trimempty = true })

        local node = root
        for i, part in ipairs(parts) do
            if not node.children[part] then
                node.children[part] = {
                    name       = part,
                    children   = {},
                    is_file    = false,
                    abs        = nil,
                    parent     = node,
                    size       = 0,
                    mtime      = 0,
                    git_status = "  ",
                }
            end

            node = node.children[part]

            if i == #parts then
                node.is_file = true
                node.abs     = abs

                local stat = vim.loop.fs_stat(abs)
                if stat then
                    node.size  = stat.size or 0
                    node.mtime = stat.mtime and stat.mtime.sec or 0
                else
                    node.size  = 0
                    node.mtime = 0
                end

                node.git_status = git_status[rel] or "  "
            end
        end
    end

    for _, rel in ipairs(rel_files) do
        if rel ~= "" then
            insert_abs(config.options.dir .. "/" .. rel)
        end
    end

    local function compute_folder_stats(node)
        if node.is_file then
            return node.size, node.mtime
        end

        local total_size   = 0
        local latest_mtime = 0

        for _, child in pairs(node.children) do
            local size, mtime = compute_folder_stats(child)
            total_size = total_size + size
            if mtime > latest_mtime then
                latest_mtime = mtime
            end
        end

        node.size  = total_size
        node.mtime = latest_mtime

        return total_size, latest_mtime
    end

    compute_folder_stats(root)

    local function compute_folder_git_status(node)
        if node.is_file then
            return node.git_status
        end

        local folder_status = "  "

        for _, child in pairs(node.children) do
            local st = compute_folder_git_status(child)
            if st ~= "  " then
                folder_status = "M "
            end
        end

        node.git_status = folder_status
        return folder_status
    end

    compute_folder_git_status(root)

    return root
end

function M.build()
    return build_tree()
end

return M
