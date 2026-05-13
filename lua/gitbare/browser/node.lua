local config = require("gitbare.config")

local M = {}

function M.find(abs, root)
    if not vim.startswith(abs, config.options.dir .. "/") then
        return nil, nil
    end

    local rel   = abs:sub(#config.options.dir + 2)
    local parts = vim.split(rel, "/", { plain = true, trimempty = true })

    local node   = root
    local parent = nil

    for _, part in ipairs(parts) do
        if not node.children[part] then
            return nil, nil
        end
        parent = node
        node   = node.children[part]
    end

    return node, parent
end

function M.is_dotfile(abs, root)
    local node = M.find(abs, root)
    return node and node.is_file
end

function M.from_entry(entry)
    if entry.node then return entry.node end
    if entry.value and entry.value.node then return entry.value.node end
    if entry.target then return entry.target end
    return nil
end

return M
