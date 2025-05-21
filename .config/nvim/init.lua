
require("_lazy")


-- vim.opt.tabstop=4

-- Disable LSP semantic syntax highlighting 
for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
        vim.api.nvim_set_hl(0, group, {})
end

-- Set up folding
-- vim.cmd([[set foldenable]])
-- no folds when we open a new buffer
-- vim.opt.foldlevel = 20
-- vim.opt.foldlevelstart = 99
-- how deeply code gets folded
-- vim.opt.foldnestmax = 4

-- use treesitter to decide on what to fold
-- vim.opt.foldmethod = "syntax"
-- the following makes it slow!
-- vim.opt.foldmethod = "expr"
-- vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"


-- The following is a quick and dirty way of setting up a second tab with Fugitive
-- Ideally, if we knew Lua and the Neovim API better, we could loop through the existing
-- tabs. If only one exists, rename this and create a second one named "Fugitive".
-- If more than one exists, then check if one named Fugitive exists and if not, create it.
local function git_tab()
  vim.cmd("Tabby rename_tab Code")
  vim.cmd("tabnew")
  vim.cmd("Tabby rename_tab Fugitive")
  vim.cmd("Git")
end
vim.api.nvim_create_user_command('Fig', git_tab, {})

