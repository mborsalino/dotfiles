
require("_lazy")


-- vim.opt.tabstop=4

-- Disable LSP semantic syntax highlighting 
for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
        vim.api.nvim_set_hl(0, group, {})
end


