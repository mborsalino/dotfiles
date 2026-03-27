return {
    "ellisonleao/glow.nvim",
    cmd = "Glow",
    keys = {
        -- open glow floating preview of current markdown file
        -- Mnemonic: markdown glow
        { "<Leader>mg", "<cmd>Glow<CR>", ft = "markdown", desc = "Markdown glow preview" },
    },
    opts = {
        border = "rounded",
        width_ratio = 0.85,
        height_ratio = 0.85,
    },
}
