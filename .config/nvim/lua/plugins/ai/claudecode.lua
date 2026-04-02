return {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = function(_, opts)
        require("claudecode").setup(opts)
        -- Allow <C-h> to navigate out of the Claude terminal pane
        vim.api.nvim_create_autocmd("TermOpen", {
            pattern = "*",
            callback = function()
                vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { buffer = true })
                vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { buffer = true })
            end,
        })
    end,
    -- Keybindings: <Leader>a = AI, c = claude, then action
    keys = {
        { "<Leader>act", "<cmd>ClaudeCode<cr>", desc = "AI Claude toggle" },
        { "<Leader>acs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "AI Claude send selection" },
        { "<Leader>acd", "<cmd>ClaudeCodeAdd<cr>", desc = "AI Claude add file" },
    },
}
