return {
    "denxeiy/gitbare.nvim",
    dependencies = {
        "telescope-nvim/telescope.nvim", -- dependency for beautiful UI windows and navigation
        "nvim-tree/nvim-web-devicons", -- dependency for beautiful colorful icons
    },
    config = function ()
        require("gitbare").setup({ -- setup is strongly required, maybe won't work without it
            dir = "/home/user", -- or any other directory. i prefer to use $HOME
            git_dir_name = ".git", -- or .*any*, depends on how you named it if your place
            find_in_current_dir = false, -- false - search system-wide in your bare git repo, true - only in current dir (pwd)
            grep_in_current_dir = false, -- same as above but for live grep, search by words
        })
        vim.keymap.set("n", "<leader>cb", function() -- file browser, you can put keymap in your separate file with mappings or change keys here
                require("gitbare").gitbare_browser() -- if you will set keymap somewhere else - do it with this function()
        end, { desc = "GitBare File Browser" }) -- if you don't need this bind - just comment it with "--" on left side

        vim.keymap.set("n", "<leader>cf", function() -- find files, you can put keymap in your separate file with mappings or change keys here
            require("telescope.builtin").gitbare_find_files() -- if you will set keymap somewhere else - do it with this function()
        end, { desc = "GitBare Find Files" }) -- if you don't need this bind - just comment it with "--" on left side

        vim.keymap.set("n", "<leader>cg", function() -- live grep, you can put keymap in your separate file with mappings or change keys here
            require("telescope.builtin").gitbare_live_grep() -- if you will set keymap somewhere else - do it with this function()
        end, { desc = "GitBare Live Grep" }) -- if you don't need this bind - just comment it with "--" on left side
    end, -- at the end of installation you can remove all of my silly comments like this one :)
}
