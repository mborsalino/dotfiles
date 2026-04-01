return {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    build = "make",
    opts = {
        provider = "claude",
        claude = {
            model = "claude-sonnet-4-6-20250514",
            max_tokens = 4096,
        },
        -- Default keybindings (made explicit for clarity)
        mappings = {
            ask = "<Leader>aa",       -- Open chat sidebar
            edit = "<Leader>ae",      -- Edit selected code with AI
            refresh = "<Leader>ar",   -- Regenerate response
            toggle = {
                default = "<Leader>at", -- Toggle sidebar visibility
            },
            focus = "<Leader>af",     -- Switch focus between sidebar and code
        },
    },
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "echasnovski/mini.icons",
    },
}
