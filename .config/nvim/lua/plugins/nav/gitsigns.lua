-- gitsigns.nvim — replaced vim-gitgutter
-- Allow two sign columns so gitsigns and diagnostics don't fight for the same slot
vim.opt.signcolumn = "auto:2"

return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    -- Same symbols as vim-gitgutter defaults
    signs = {
      add          = { text = "+" },
      change       = { text = "~" },
      delete       = { text = "_" },
      topdelete    = { text = "‾" },
      changedelete = { text = "~" },
      untracked    = { text = "┆" },
    },
    -- Separate signs for staged changes (same glyphs, distinguishable via highlight)
    signs_staged = {
      add          = { text = "+" },
      change       = { text = "~" },
      delete       = { text = "_" },
      topdelete    = { text = "‾" },
      changedelete = { text = "~" },
      untracked    = { text = "┆" },
    },
    -- Show staged signs alongside unstaged ones
    signs_staged_enable = true,
    -- Show signs in the sign column
    signcolumn = true,
    -- Don't highlight line numbers for changed lines
    numhl = false,
    -- Don't highlight the whole line for changed lines
    linehl = false,
    -- Don't show intra-line word diffs (toggle with :Gitsigns toggle_word_diff)
    word_diff = false,
    -- Watch .git dir for external changes (e.g. git commit from terminal)
    watch_gitdir = {
      follow_files = true,
    },
    -- Automatically attach to buffers
    auto_attach = true,
    -- Don't attach to untracked files
    attach_to_untracked = false,
    -- Don't show blame on current line by default (toggle with :Gitsigns toggle_current_line_blame)
    current_line_blame = false,
    current_line_blame_opts = {
      virt_text = true,
      -- Show blame at end of line
      virt_text_pos = "eol",
      -- Delay before showing blame (ms)
      delay = 1000,
      ignore_whitespace = false,
      virt_text_priority = 100,
      -- Only show blame when buffer is focused
      use_focus = true,
    },
    -- Format: "author, 3 days ago - commit message"
    current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
    -- Priority of gitsigns signs relative to other sign providers
    sign_priority = 6,
    -- Debounce time (ms) for updates after buffer changes
    update_debounce = 100,
    -- Disable for files longer than 40k lines
    max_file_length = 40000,
    -- Floating window config for hunk previews
    preview_config = {
      style = "minimal",
      relative = "cursor",
      row = 0,
      col = 1,
    },
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns
      local map = function(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end

      -- Navigation (matching vim-gitgutter custom bindings)
      map("n", "<Leader>hn", function()
        if vim.wo.diff then return "]c" end
        vim.schedule(function() gs.next_hunk() end)
        return "<Ignore>"
      end, "Next hunk")

      map("n", "<Leader>hp", function()
        if vim.wo.diff then return "[c" end
        vim.schedule(function() gs.prev_hunk() end)
        return "<Ignore>"
      end, "Prev hunk")

      -- Actions (matching vim-gitgutter custom bindings)
      map("n", "<Leader>hv", gs.preview_hunk, "Preview hunk")
      map("n", "<Leader>hs", gs.stage_hunk, "Stage hunk")
      map("n", "<Leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
      map("n", "<Leader>hr", gs.reset_hunk, "Reset hunk")
      map("n", "<Leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
      map("n", "<Leader>hd", gs.diffthis, "Diff this file")
    end,
  },
}
