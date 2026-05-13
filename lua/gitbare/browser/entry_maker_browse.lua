local node_mod = require("gitbare.browser.node")
local fmt      = require("gitbare.browser.format")
local devicons = require("nvim-web-devicons")

local M = {}

-- Create a Telescope entry for a file/dir/up item
function M.entry(entry)
    local icon, icon_hl
    local node = node_mod.from_entry(entry)

    -- Determine icon
    if entry.kind == "dir" then
        icon    = ""
        icon_hl = "Directory"
    elseif entry.kind == "up" then
        icon    = ""
        icon_hl = "Directory"
    else
        local filename = entry.abs
            and vim.fn.fnamemodify(entry.abs, ":t")
            or entry.display

        icon, icon_hl = devicons.get_icon(filename, nil, { default = true })
    end

    -- Extract node metadata (safe defaults)
    local size    = node and node.size or 0
    local mtime   = node and node.mtime or 0
    local raw_git = node and node.git_status or " "
    local git     = fmt.normalize_git_status(raw_git)

    -- Precompute formatted columns
    local name_col = fmt.truncate_or_pad(entry.display, fmt.NAME_WIDTH_ENTRY)
    local git_col  = fmt.pad_right(git, fmt.GIT_WIDTH)
    local size_col = fmt.pad_left(fmt.format_size(size), fmt.SIZE_WIDTH)
    local date_col = fmt.pad_left(fmt.format_mtime(mtime), fmt.DATE_WIDTH)

    return {
        value   = entry,
        ordinal = entry.ordinal,
        path    = (entry.kind == "file") and entry.abs or "",

        -- Display callback for Telescope
        display = function()
            local icon_col = fmt.pad_right(icon, fmt.ICON_WIDTH)

            local text = string.format(
                "%s %s %s %s %s",
                icon_col,
                name_col,
                git_col,
                size_col,
                date_col
            )

            local hl = {
                { { 0, fmt.ICON_WIDTH }, icon_hl },
            }

            return text, hl
        end,
    }
end

return M
