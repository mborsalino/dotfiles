return {
  "hedyhli/outline.nvim",
  lazy = true,
  cmd = { "Outline", "OutlineOpen" },
  keys = { -- Example mapping to toggle outline
    { "<leader>oo", "<cmd>Outline<CR>", desc = "Toggle outline" },
    { "<leader>of", "<cmd>OutlineFocusOutline<CR>", desc = "Switch Focus to Outline Window" },
  },
  opts = {
    -- Enable single-click to jump to symbol from outline window
    keymaps = {
      goto_location = { '<CR>', '<2-LeftMouse>' },
    },
  },
}
