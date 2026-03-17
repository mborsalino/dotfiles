return {
    "rcarriga/nvim-notify",
    config = function()
        local notify = require("notify")
        notify.setup({
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
        })
        vim.notify = notify
    end,
}
