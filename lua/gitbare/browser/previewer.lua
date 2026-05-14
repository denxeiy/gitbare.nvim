local fmt        = require("gitbare.browser.format")
local devicons   = require("nvim-web-devicons")
local previewers = require("telescope.previewers")

local M = {}

function M.define_preview(self, entry, _)
    local value = entry.value

    if value.kind == "file" then
        return previewers.buffer_previewer_maker(
            value.abs,
            self.state.bufnr,
            { bufname = self.state.bufname }
        )
    end

    if value.kind == "up" then
        value = { kind = "dir", node = value.target }
    end

    local node = value.node
    if not node then
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { "Empty" })
        return
    end

    local items = {}

    for name, child in pairs(node.children) do
        local icon, icon_hl

        if child.is_file then
            icon, icon_hl = devicons.get_icon(name, nil, { default = true })
        else
            icon    = ""
            icon_hl = "Directory"
        end

        table.insert(items, {
            name    = name,
            is_file = child.is_file,
            icon    = icon,
            icon_hl = icon_hl,
            size    = child.size,
            mtime   = child.mtime,
            git     = fmt.normalize_git_status(child.git_status)
        })
    end

    table.sort(items, function(a, b)
        if a.is_file ~= b.is_file then
            return a.is_file
        end
        return a.name < b.name
    end)

    local lines = {}

    for _, it in ipairs(items) do
        local name_col = fmt.truncate_or_pad(it.name, fmt.NAME_WIDTH_PREVIEWER)
        -- local git_col  = fmt.pad_right(it.git, fmt.GIT_WIDTH)
        local git_col  = it.git
        local size_col = fmt.pad_left(fmt.format_size(it.size), fmt.SIZE_WIDTH)
        local date_col = fmt.pad_left(fmt.format_mtime(it.mtime), fmt.DATE_WIDTH)

        local icon_col = fmt.pad_right(it.icon, fmt.ICON_WIDTH)
        local line = string.format(
            "%s %s %s %s %s",
            icon_col,
            git_col,
            name_col,
            size_col,
            date_col
        )
        table.insert(lines, line)
    end

    vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)

    for i, it in ipairs(items) do
        vim.api.nvim_buf_add_highlight(
            self.state.bufnr,
            -1,
            it.icon_hl,
            i - 1,
            0,
            fmt.ICON_WIDTH
        )
    end
end

return M
