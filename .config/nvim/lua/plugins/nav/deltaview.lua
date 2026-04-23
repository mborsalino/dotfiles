return {
  "kokusenz/deltaview.nvim",
  dependencies = {
    "kokusenz/delta.lua",
  },
  cmd = { "DeltaView", "DeltaMenu", "Delta" },
  keys = {
    -- Mnemonic: delta line (inline diff of current file)
    { "<Leader>dl", "<cmd>DeltaView<cr>", desc = "DeltaView (inline diff)" },
    -- Mnemonic: delta menu (pick from all modified files)
    { "<Leader>dm", "<cmd>DeltaMenu<cr>", desc = "DeltaMenu (modified files)" },
    -- Mnemonic: delta all (context diff for path)
    { "<Leader>da", "<cmd>Delta<cr>", desc = "Delta (context diff)" },
  },
  opts = {
    fzf_picker = "telescope",
  },
}
