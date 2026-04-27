-- icicle: iceberg variant with adjusted string colors and diff highlights
-- Axolotl-inspired diffs: removed lines fade, added lines pop.
vim.cmd("colorscheme iceberg")

-- Iceberg palette reference:
--   String:        #89b8c2   (muted teal, we darken it)
--   Comment grey:  #6b7089   (faded, "going away")
--   Warm orange:   #e2a478   (bright, "look at me")
--   Blue:          #84a0c6
--   Background:    #161821
--   Subtle bg:     #1e2132

-- Strings: dimmer teal than iceberg default
vim.api.nvim_set_hl(0, "String", { fg = "#6a9aa4" })

-- Neogit diff: removed lines fade (dark grey), added lines pop (orange)
vim.api.nvim_set_hl(0, "NeogitDiffDelete",          { fg = "#4e5066", bg = "#0e1019" })
vim.api.nvim_set_hl(0, "NeogitDiffDeleteHighlight",  { fg = "#4e5066", bg = "#1a1c25" })
vim.api.nvim_set_hl(0, "NeogitDiffDeleteCursor",     { fg = "#4e5066", bg = "#1a1c25" })
vim.api.nvim_set_hl(0, "NeogitDiffDeletions",        { fg = "#4e5066" })
vim.api.nvim_set_hl(0, "NeogitDiffDeleteInline",     { fg = "#4e5066", bg = "#1e2132", bold = true })

vim.api.nvim_set_hl(0, "NeogitDiffAdd",              { fg = "#e2a478", bg = "#0e1019" })
vim.api.nvim_set_hl(0, "NeogitDiffAddHighlight",     { fg = "#e2a478", bg = "#1a1c25" })
vim.api.nvim_set_hl(0, "NeogitDiffAddCursor",        { fg = "#e2a478", bg = "#1a1c25" })
vim.api.nvim_set_hl(0, "NeogitDiffAdditions",        { fg = "#e2a478" })
vim.api.nvim_set_hl(0, "NeogitDiffAddInline",        { fg = "#e2a478", bg = "#1e2132", bold = true })

vim.api.nvim_set_hl(0, "NeogitDiffContext",           { bg = "#0e1019" })
vim.api.nvim_set_hl(0, "NeogitDiffContextHighlight",  { bg = "#1a1c25" })
vim.api.nvim_set_hl(0, "NeogitDiffContextCursor",     { bg = "#1a1c25" })

-- Neogit hunk/diff headers
vim.api.nvim_set_hl(0, "NeogitHunkHeader",            { fg = "#161821", bg = "#e8e4a0", bold = true })
vim.api.nvim_set_hl(0, "NeogitHunkHeaderHighlight",   { fg = "#161821", bg = "#e8e4a0", bold = true })
vim.api.nvim_set_hl(0, "NeogitHunkHeaderCursor",      { fg = "#161821", bg = "#e8e4a0", bold = true })

vim.api.nvim_set_hl(0, "NeogitDiffHeader",            { fg = "#84a0c6", bg = "#2a3158", bold = true })
vim.api.nvim_set_hl(0, "NeogitDiffHeaderHighlight",   { fg = "#84a0c6", bg = "#2a3158", bold = true })

-- Diffview: same philosophy, delta's #FFB030 orange for additions
vim.api.nvim_set_hl(0, "DiffDelete",  { fg = "#4e5066", bg = "#0e1019" })
vim.api.nvim_set_hl(0, "DiffAdd",     { fg = "#FFB030", bg = "#161821" })
vim.api.nvim_set_hl(0, "DiffChange",  { bg = "#161821" })
vim.api.nvim_set_hl(0, "DiffText",    { fg = "#FFB030", bg = "#252a3a" })
