local M = {}

M.NAME_WIDTH_PREVIEWER = 41
M.NAME_WIDTH_ENTRY = 31
M.GIT_WIDTH  = 2
M.SIZE_WIDTH = 10
M.DATE_WIDTH = 16
M.ICON_WIDTH = 2

function M.normalize_git_status(git)
    if git == nil then
        return " "
    end

    if git == "" then
        return " "
    end

    local a = git:sub(1,1)
    local b = git:sub(2,2)

    if a ~= " " and a ~= "" then
        return a
    end

    if b ~= " " and b ~= "" then
        return b
    end

    return " "
end

function M.truncate_or_pad(str, width)
    local function display_cut(s, w)
        local out = ""
        local cur = 0
        for i = 1, #s do
            local ch = s:sub(i, i)
            local cw = vim.fn.strdisplaywidth(ch)
            if cur + cw > w then break end
            out = out .. ch
            cur = cur + cw
        end
        return out, cur
    end

    local w = vim.fn.strdisplaywidth(str)

    if w <= width then
        return str .. string.rep(" ", width - w)
    end

    local ellipsis = "…"
    local ell_w = vim.fn.strdisplaywidth(ellipsis)

    local cut = display_cut(str, width - ell_w)
    local final = cut .. ellipsis

    local final_w = vim.fn.strdisplaywidth(final)
    if final_w < width then
        final = final .. string.rep(" ", width - final_w)
    elseif final_w > width then
        final, _ = display_cut(final, width)
    end

    return final
end

function M.format_size(bytes)
    if not bytes then return "0 B" end
    if bytes < 1024 then return bytes .. " B" end
    if bytes < 1024 * 1024 then return string.format("%.1f KB", bytes / 1024) end
    if bytes < 1024 * 1024 * 1024 then return string.format("%.1f MB", bytes / 1024 / 1024) end
    return string.format("%.1f GB", bytes / 1024 / 1024 / 1024)
end

function M.format_mtime(sec)
    if not sec or sec == 0 then return "—" end
    return os.date("%d.%m.%Y %H:%M", sec)
end

local function cut_display(str, width)
    local out = ""
    local cur = 0

    for i = 1, #str do
        local ch = str:sub(i, i)
        local cw = vim.fn.strdisplaywidth(ch)
        if cur + cw > width then break end
        out = out .. ch
        cur = cur + cw
    end

    return out
end

function M.pad_left(str, width)
    local w = vim.fn.strdisplaywidth(str)

    if w == width then
        return str
    elseif w < width then
        return string.rep(" ", width - w) .. str
    else
        return cut_display(str, width)
    end
end

function M.pad_right(str, width)
    local w = vim.fn.strdisplaywidth(str)
    if w < width then
        return str .. string.rep(" ", width - w)
    elseif w > width then
        local out = ""
        local cur = 0
        for i = 1, #str do
            local ch = str:sub(i, i)
            local cw = vim.fn.strdisplaywidth(ch)
            if cur + cw > width then break end
            out = out .. ch
            cur = cur + cw
        end
        return out
    end
    return str
end

return M
