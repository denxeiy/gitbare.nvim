return {
    "denxeiy/gitbare.nvim",
    dependencies = {
        "telescope-nvim/telescope.nvim",
        "telescope-nvim/telescope-file-browser.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    config = function ()
        require("gitbare").setup({
            dir = "/home/user", -- or any other directory. i prefer to use $HOME
            git_dir_name = ".git", -- or .any, depends on how you named it
            find_in_current_dir = false, -- false - search system-wide in your bare git repo, true - only in current dir
            grep_in_current_dir = false, -- same as above but for live grep
        })
        vim.keymap.set("n", "<leader>cb", function() -- file browser, you can put keymap in your separate file with mappings or change keys here
                require("gitbare").gitbare_browser()
        end, { desc = "GitBare File Browser" })

        vim.keymap.set("n", "<leader>cf", function()
            require("telescope.builtin").gitbare_find_files() -- find files, you can put keymap in your separate file with mappings or change keys here
        end, { desc = "GitBare Find Files" })

        vim.keymap.set("n", "<leader>cg", function()
            require("telescope.builtin").gitbare_live_grep() -- live grep, you can put keymap in your separate file with mappings or change keys here
        end, { desc = "GitBare Live Grep" })
    end,
}
