local M = {}

local function git_list_files(gitdir)
    return vim.fn.systemlist(
        string.format('git --git-dir="%s" ls-tree -r --name-only HEAD', gitdir)
    )
end

local function git_status_map(gitdir, dir)
    local lines = vim.fn.systemlist(
        string.format('git --git-dir="%s" --work-tree="%s" status --porcelain', gitdir, dir)
    )

    local map = {}
    for _, line in ipairs(lines) do
        if line ~= "" then
            local status = line:sub(1, 2)
            local path = line:sub(4)
            map[path] = status
        end
    end
    return map
end

function M.scan_repo(dir, gitdir)
    local files = git_list_files(gitdir)
    local statuses = git_status_map(gitdir, dir)

    local results = {}

    for _, rel in ipairs(files) do
        table.insert(results, {
            path = dir .. "/" .. rel,
            status = statuses[rel] or "  ",
        })
    end

    return results
end

return M
