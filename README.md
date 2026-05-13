# **I. GitBare.nvim**

Plugin for Neovim to search files, words and navigate through your "bare" git repository.

Decided to make one because couldn't find any in GitHub. There is some plugins, like fugitive and ":Telescope git_files" command from telescope, but they were not enough and didn't work with "bare's" the way i wanted to.

---------------------
# **II. Installation**

```lua
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
```
You can take this block of code and put in lazy or download file from repo and put it in your directory, where stored all of your plugins.
I only use Lazy plugin manager, so here is setup config for lazy only.

If you got other plugin manager - i hope you'll figure out how install gitbare.nvim. If not - leave a issue and we'll figure it out together eventually.

---------------------
# **III. How it works**

**File browser** - making the tree with parent-child system from all of your paths to files in git with: date and time of last change, git status, sizes, names.

Then it creates preview window and picker window from Telescope builtin functions and lets you see git repo as file system.

**Find files and live grep** - taking file list and statuses from git. Then making picker window as described above. Find files - just search files or directories with keywords in your git tracked paths, live grep - search words inside files.

Just like Telescope itself with its ":Telescope find_files" and ":Telescope live_grep". But only in specific paths.

All you have to do to start is set this 2 fields:
- dir - directory where folder ".git" presents;
- git_dir_name - by default is ".git". Change this parameter if your git-directory's name is different.

---------------------
# **IV. Dependencies**

1. Neovim 0.8+
2. [telescope-nvim/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
3. [nvim-tree/nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)
4. Git (if you ain't got git - maybe you don't need this plugin. In case you do - search web for ways to install git on your specific device and OS)

---------------------
# ***LICENSE**

MIT
