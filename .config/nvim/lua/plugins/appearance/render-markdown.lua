return {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
    keys = {
        -- toggle between rendered and raw source
        -- Mnemonic: markdown render
        { "<Leader>mr", "<cmd>RenderMarkdown toggle<CR>", desc = "Markdown render toggle" },
    },
    opts = {
        enabled = false,   -- start in raw source mode; toggle with <Leader>mr
    },
}
