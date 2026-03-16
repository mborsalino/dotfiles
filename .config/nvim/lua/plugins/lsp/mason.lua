return {
  "williamboman/mason.nvim",
  version = "1.11.0",
  dependencies = {
    {"williamboman/mason-lspconfig.nvim",
     version="1.32.0"
    },
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    -- import mason
    local mason = require("mason")

    -- import mason-lspconfig
    local mason_lspconfig = require("mason-lspconfig")

    local mason_tool_installer = require("mason-tool-installer")

    -- enable mason and configure icons
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_lspconfig.setup({
      -- list of servers for mason to install
      ensure_installed = {
        "lua_ls",
        -- rust installed separately to use system rust-analyzer
        -- "rust_analyzer",
        "clangd",
        -- "pylsp", -- pyright is an alternative
        -- "pyre"
        "ruff",
      },
      -- auto-install configured servers (with lspconfig)
      automatic_installation = true, -- not the same as ensure_installed
      -- Disable automatic vim.lsp.enable() for installed servers.
      -- Without this, mason-lspconfig auto-enables every installed server,
      -- causing duplicates when servers are also explicitly set up via
      -- lspconfig[server].setup() or vim.lsp.enable() in lspconfig.lua.
      automatic_enable = false,
    })

    mason_tool_installer.setup({
      ensure_installed = {
        "clang-format",
        "prettier", -- prettier formatter
        "stylua", -- lua formatter
        -- ruff is already in mason_lspconfig ensure_installed
        "jedi-language-server",
      },
    })
  end,
}
