return {
    BareBrowser = function()
        require("gitbare.browser.browser").gitbare_browser()
    end,

    BareFiles = function()
        require("gitbare.grep_find.find_files").find_files()
        end,

    BareGrep = function()
        require("gitbare.grep_find.live_grep").live_grep()
    end,
}
