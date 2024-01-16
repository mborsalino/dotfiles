return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        path_display = { "truncate " },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous, -- move to prev result
            ["<C-j>"] = actions.move_selection_next, -- move to next result
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          },
        },
      },
    })

    telescope.load_extension("fzf")

    -- set keymaps
    local keymap = vim.keymap -- for conciseness

    -- do not map the following. while convenient, it makes the current
    -- <leader>f keybinding (for fzf.vim) slower since it waits for a second letter for 2 seconds
   keymap.set("n", "<leader>tf", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
   keymap.set("n", "<leader>tr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
   keymap.set("n", "<leader>tj", "<cmd>Telescope jumplist<cr>", { desc = "Fuzzy find jumplist" })
   keymap.set("n", "<leader>k", "<cmd>Telescope keymaps<cr>", { desc = "Find vim keybinding" })
   -- see also <leader>th defined in harpoon.lua

   -- keymap.set("n", "<leader>ts", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
   -- keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })

  end,
}
