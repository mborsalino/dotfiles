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
    telescope.load_extension("aerial")

    -- set keymaps
    local keymap = vim.keymap -- for conciseness

    -- do not map the following. while convenient, it makes the current
    -- <leader>f keybinding (for fzf.vim) slower since it waits for a second letter for 2 seconds
   keymap.set("n", "<leader>tf", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
   keymap.set("n", "<leader>tr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
   keymap.set("n", "<leader>tj", "<cmd>Telescope jumplist<cr>", { desc = "Fuzzy find jumplist" })
   keymap.set("n", "<leader>tk", "<cmd>Telescope keymaps<cr>", { desc = "Find vim keybinding" })
   keymap.set("n", "<leader>tb", "<cmd>Telescope buffers<cr>", { desc = "Find vim keybinding" })
   keymap.set("n", "<leader>tbt", "<cmd>Telescope current_buffer_tags<cr>", { desc = "Find tags in current buffer" })
   keymap.set("n", "<leader>tpt", "<cmd>Telescope tags<cr>", { desc = "Find tags in current project" })
   keymap.set("n", "<leader>tls", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "Find LSP symbols in current buffer" })
   keymap.set("n", "<leader>tas", "<cmd>Telescope aerial<cr>", { desc = "Find aerial symbols in current buffer" })
   -- see also <leader>th defined in harpoon.lua
   -- see also <leader>ttb defined in telescope_tabs.lua

   -- keymap.set("n", "<leader>ts", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
   -- keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })

  end,
}
