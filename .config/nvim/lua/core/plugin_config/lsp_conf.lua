-- Use mason as frontend "LSP server manager"
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {"lua_ls", "rust_analyzer", "clangd", "pylsp"}
})

-- Use lsp-zero to setup keymaps for code navigation
-- local lsp = require('lsp-zero').preset({
--     manage_nvim_cmp = {
--         set_sources = 'recommended'
--     }
-- })
-- lsp.on_attach(function(client, bufnr)
--     lsp.default_keymaps({buffer = bufnr})
-- end)

-- Setup individual LSP servers
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lspconfig = require('lspconfig')

lspconfig.lua_ls.setup {
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        -- Get the language server to recognize the 'vim' global
        globals = {'vim'},
      }
    }
  }
}

lspconfig.clangd.setup {
  capabilities = capabilities
}

lspconfig.rust_analyzer.setup {
  capabilities = capabilities
}

lspconfig.pylsp.setup {
  capabilities = capabilities,
  settings = {
      pylsp = {
          plugins = {
              pycodestyle = {
                  ignore = {'E203', -- whitespace before : 
                            'E228', -- space around modulo  
                            'E503', -- line break before binary operator
                            'E501', -- line too long 
                            'E303', -- too many blank lines
                            'W504', -- line break after binary operator
                            'E127', -- continuation line over-indented
                            'E128', -- continuation line under-indented
                            'E124', -- closing bracket doesn't match visual indentation
                           }
              }
          }
      }
  }
}

-- Setup autocompletion
local cmp = require'cmp'
cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    -- ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    -- ['<C-f>'] = cmp.mapping.scroll_docs(4),
    -- ['<C-Space>'] = cmp.mapping.complete(),
    -- ['<C-e>'] = cmp.mapping.abort(),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'nvim_lsp_signature_help' }
  }, {
    { name = 'buffer' },
  })
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'async_path' }
  }, {
    { name = 'cmdline' }
  })
})

-- Disable LSP semantic syntax highlighting 
for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
        vim.api.nvim_set_hl(0, group, {})
end

-- Toggle LSP Diagonistic on and off (server still running, but do not display errs/warnings)
local diagnostics_active = true
vim.keymap.set('n', '<leader>dt', function()
  diagnostics_active = not diagnostics_active
  if diagnostics_active then
    vim.diagnostic.show()
  else
    vim.diagnostic.hide()
  end
end)

-- Uncomment this if you're annoied by the inline diagnostics
-- vim.diagnostic.config({
--   virtual_text = false, -- Turn off inline diagnostics
-- })

-- Show all diagnostics on current line in floating window
vim.api.nvim_set_keymap(
  'n', '<Leader>ds', ':lua vim.diagnostic.open_float()<CR>',
  { noremap = true, silent = true }
)
-- Go to next diagnostic (if there are multiple on the same line, only shows
-- one at a time in the floating window)
vim.api.nvim_set_keymap(
  'n', '<Leader>dn', ':lua vim.diagnostic.goto_next()<CR>',
  { noremap = true, silent = true }
)
-- Go to prev diagnostic (if there are multiple on the same line, only shows
-- one at a time in the floating window)
vim.api.nvim_set_keymap(
  'n', '<Leader>dp', ':lua vim.diagnostic.goto_prev()<CR>',
  { noremap = true, silent = true }
)
