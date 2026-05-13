local M = {}

-- Open a node inside the bare repo tree
local function open_node(current)
    local entries = {}

    -- Add "up" entry if parent exists
    if current.parent ~= nil then
        table.insert(entries, {
            kind    = "up",
            display = "..",
            ordinal = "../",
            target  = current.parent,
        })
    end

    -- Add directories first
    for name, child in pairs(current.children) do
        if not child.is_file then
            table.insert(entries, {
                kind    = "dir",
                display = name,
                ordinal = name .. "/",
                node    = child,
            })
        end
    end

    -- Add files second
    for name, child in pairs(current.children) do
        if child.is_file then
            table.insert(entries, {
                kind    = "file",
                display = name,
                ordinal = name,
                abs     = child.abs,
                node    = child,
            })
        end
    end

    -- Lazy-load Telescope modules
    local pickers      = require("telescope.pickers")
    local finders      = require("telescope.finders")
    local conf         = require("telescope.config").values
    local actions      = require("telescope.actions")
    local action_st    = require("telescope.actions.state")
    local previewers   = require("telescope.previewers")
    local entry_maker_browse  = require("gitbare.browser.entry_maker_browse")
    local def_prev     = require("gitbare.browser.previewer")

    pickers
        .new({}, {
            prompt_title = "GitBare File Browser",

            finder = finders.new_table({
                results     = entries,
                entry_maker = entry_maker_browse.entry,
            }),

            sorter = conf.generic_sorter({}),

            previewer = previewers.new_buffer_previewer({
                define_preview = def_prev.define_preview,
            }),

            attach_mappings = function(_, map)
                local function open_selected(prompt_bufnr)
                    local selection = action_st.get_selected_entry()
                    if not selection then return end

                    local entry = selection.value
                    actions.close(prompt_bufnr)

                    local function normalize_path(path)
                        if not path or path == "" or path == "." then
                            return vim.loop.cwd()
                        end
                        return path
                    end

                    if entry.kind == "up" then
                        return open_node(entry.target)

                    elseif entry.kind == "dir" then
                        return open_node(entry.node)

                    elseif entry.kind == "file" then
                        local path = normalize_path(entry.abs)
                        vim.cmd("edit " .. path)
                    end
                end

                map("i", "<CR>", open_selected)
                map("n", "<CR>", open_selected)

                return true
            end,
        })
        :find()
end

-- Public API
function M.open(node)
    return open_node(node)
end

return M
