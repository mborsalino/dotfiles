return {
    "rainbowhxch/beacon.nvim",
    event = "VeryLazy",
    opts = {
        speed = 2,          -- animation speed (smaller = faster)
        width = 40,         -- beacon width
        winblend = 70,      -- transparency (0 = opaque, 100 = invisible)
        fps = 60,           -- frames per second
        min_jump = 1,       -- minimum jump distance to trigger
    },
    config = function(_, opts)
        require("beacon").setup(opts)
        -- Re-apply Beacon highlight after colorscheme changes
        vim.api.nvim_create_autocmd("ColorScheme", {
            callback = function()
                vim.cmd([[highlight BeaconDefault guibg=white ctermbg=15]])
                vim.cmd([[highlight! link Beacon BeaconDefault]])
            end,
        })
    end,
    keys = {
        -- "where am I" — flash cursor on demand
        { "<Leader>w", "<cmd>Beacon<CR>", desc = "Flash cursor (where am I)" },
    },
}
