return {
    -- no-clown-fiesta colorscheme
    { 'aktersnurra/no-clown-fiesta.nvim',
      config = function()
          require("no-clown-fiesta").setup({
            transparent = false, -- Enable this to disable the bg color
            styles = {
              -- You can set any of the style values specified for `:h nvim_set_hl`
              comments = {},
              keywords = {},
              functions = {},
              variables = {},
              type = { bold = true },
              lsp = { underline = true }
            },
          })
      end
  },

  -- base16 colorschemes
  { 'RRethy/nvim-base16' },

  -- catppuccin colorscheme (official, full palette — not the base16 approximation)
  { 'catppuccin/nvim', name = 'catppuccin' },

  -- rose-pine colorscheme
  { 'rose-pine/neovim', name='rose-pine'},

  -- zenbones colorscheme
  { 'mcchrish/zenbones.nvim',
      dependencies = { "rktjmp/lush.nvim" }
    }

}
