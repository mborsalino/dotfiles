-- Bootstrap lazy if it's not installed yet
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Require and configure lazy
require("lazy").setup(
    { 
        {import = "plugins" },
        {import = "plugins.nav" },
        {import = "plugins.appearance" },
        {import = "plugins.lsp" },
        {import = "vim" }, -- needed to source legacy vimrc that uses vim-plug
    },
    {
        checker = {
            enabled = true,
            notify = false,
        },
        change_detection = {
            notify = false,
        },
        reset_pack_path=false,
        rtp =  {
            reset = false  -- do not reset packpath sincce we set it in vimrc
        }
    }
)

