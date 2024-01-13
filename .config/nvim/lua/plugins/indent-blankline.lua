return {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
        local ibl = require"ibl"
        ibl.setup({
            enabled = true,
            indent = {
                char = "┊",
                smart_indent_cap = true
            }
        })

        -- set keybinds
        local keymap = vim.keymap -- for conciseness  
        local opts = {noremap = true, silent = true }

        opts.desc = "Toggle visual aligment on/off (IndentBlankLine)"
        keymap.set("n", "<leader>vat", "<cmd>IBLToggle<CR>", opts)


    end
}
