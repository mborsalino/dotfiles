return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim",
                     "nvim-telescope/telescope.nvim"},

    config = function()

        local harpoon = require("harpoon")
        local telescope = require("telescope")

        -- REQUIRED
        harpoon.setup({
            settings = {
                -- sets the marks upon calling `toggle` on the ui, instead of require `:w`
                save_on_toggle = false,

                -- saves the harpoon file upon every change
                save_on_ui_close = true,

                 -- sets harpoon to run the command immediately as it's passed to the terminal when calling `sendCommand`.
                enter_on_sendcmd = false,

                -- closes any tmux windows harpoon that harpoon creates when you close Neovim.
                tmux_autoclose_windows = false,

                -- filetypes that you want to prevent from adding to the harpoon list menu.
                excluded_filetypes = { "harpoon" },

                -- set marks specific to each git branch inside git repository
                -- Each branch will have its own set of marked files
                mark_branch = true,

                -- enable tabline with harpoon marks
                tabline = false,
                tabline_prefix = "   ",
                tabline_suffix = "   ",
            }
        })
        -- REQUIRED

        vim.keymap.set("n", "<leader>ha", function() harpoon:list():append() end)
        -- vim.keymap.set("n", "<leader>hl", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

        -- basic telescope configuration
        local conf = require("telescope.config").values
        local function toggle_telescope(harpoon_files)
            local file_paths = {}
            for _, item in ipairs(harpoon_files.items) do
                table.insert(file_paths, item.value)
            end

            require("telescope.pickers").new({}, {
                prompt_title = "Harpoon",
                finder = require("telescope.finders").new_table({
                    results = file_paths,
                }),
                previewer = conf.file_previewer({}),
                sorter = conf.generic_sorter({}),
            }):find()
        end

        vim.keymap.set("n", "<leader>tl", function() toggle_telescope(harpoon:list()) end,
                       { desc = "Open harpoon window" })
    end
}
