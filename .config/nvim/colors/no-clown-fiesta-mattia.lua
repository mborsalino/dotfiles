-- Custom variant of no-clown-fiesta-dim
-- Load the base theme first
require("no-clown-fiesta").load({ theme = "dim" })

-- Function/class names at definition site in orange (vim syntax groups)
vim.api.nvim_set_hl(0, "pythonFunction", { fg = "#FFA557" })
vim.api.nvim_set_hl(0, "pythonClass", { fg = "#FFA557" })

-- Outline plugin: current item in orange
vim.api.nvim_set_hl(0, "OutlineCurrent", { fg = "#FFA557", bold = true })

-- Search highlights: cyan background instead of orange fg (avoids clash with function names)
vim.api.nvim_set_hl(0, "Search", { bg = "#88afa2", fg = "#151515" })
vim.api.nvim_set_hl(0, "IncSearch", { bg = "#88afa2", fg = "#151515" })
vim.api.nvim_set_hl(0, "Substitute", { bg = "#88afa2", fg = "#151515" })
