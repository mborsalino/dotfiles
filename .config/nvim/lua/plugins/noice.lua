return {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
        "MunifTanjim/nui.nvim",
        {
            "rcarriga/nvim-notify",
            opts = {
                timeout = 1000,
                render = "wrapped-compact",
                stages = "fade_in_slide_out",
                max_width = 60,
                icons = {
                    ERROR = "",
                    WARN  = "",
                    INFO  = "",
                    DEBUG = "",
                    TRACE = "",
                },
            },
        },
    },
    opts = {
        views = {
            notify = {
                border = { style = "rounded" },
            },
            popup = {
                border = { style = "rounded" },
            },
            cmdline_popup = {
                border = { style = "rounded" },
            },
        },
        lsp = {
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
                ["cmp.entry.get_documentation"] = true,
            },
        },
        presets = {
            long_message_to_split = true,
            lsp_doc_border = true,
        },
    },
}
