local node_mod = require("gitbare.browser.node")
local config = require("gitbare.config")

local M = {}

local state_file = vim.fn.stdpath("data") .. "/gitbare_filter_state"

M.state = { filter = false }

function M.load_state()
    if vim.fn.filereadable(state_file) == 1 then
        local data = vim.fn.readfile(state_file)
        M.state.filter = (data[1] == "1")
    else
    end
end

function M.save_state()
    local value = M.state.filter and "1" or "0"

    local dir = vim.fn.fnamemodify(state_file, ":h")
    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, "p")
    end

    vim.fn.writefile({ value }, state_file)
end

function M.filter_entries(entries)
    if not M.state.filter then
        return entries
    end

    local filtered = {}

    for _, e in ipairs(entries) do
        local node = node_mod.from_entry(e)
        if node and node.git_status and vim.trim(node.git_status) ~= "" then
            table.insert(filtered, e)
        end
    end

    return filtered
end

function M.attach_mappings(prompt_bufnr, map, make_finder)
    local action_st = require("telescope.actions.state")

    local function toggle()
        local picker = action_st.get_current_picker(prompt_bufnr)
        M.state.filter = not M.state.filter
        M.save_state()
        picker:refresh(make_finder(), { reset_prompt = false })
    end
    local key = config.options.filter_key or "<C-f>"

    map("i", key, toggle)
    map("n", key, toggle)
end

return M
