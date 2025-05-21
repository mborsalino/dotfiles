return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  config = function()
    -- import lspconfig plugin
    local lspconfig = require("lspconfig")

    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    -- disable logging to avoid log file to grow indefinitely
    -- Turn this one on in vim by typing :lua vim.lsp.set_log_level("debug")
    vim.lsp.set_log_level("off")

    local keymap = vim.keymap -- for conciseness

    local opts = { noremap = true, silent = true }
    local on_attach = function(client, bufnr)
      opts.buffer = bufnr

      -- set keybinds
      opts.desc = "LSP: show references"
      keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

      opts.desc = "LSP: go to declaration"
      keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

      opts.desc = "LSP: show definitions"
      keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

      opts.desc = "LSP: show implementations"
      keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

      opts.desc = "LSP: type definitions"
      keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

      opts.desc = "LSP: See available code actions"
      keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

      opts.desc = "LSP: Smart rename"
      keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

      opts.desc = "Show buffer diagnostics"
      keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

      opts.desc = "Show line diagnostics"
      keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

      opts.desc = "Go to previous diagnostic"
      keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

      opts.desc = "Go to next diagnostic"
      keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

      opts.desc = "Show documentation for what is under cursor"
      keymap.set("n", "<leader>k", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

      opts.desc = "Restart LSP"
      keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary

      opts.desc = "Show code actions"
      keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)


    end

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Change the Diagnostic symbols in the sign column (gutter)
    -- (not in youtube nvim video)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- ----------------------------
    -- Setup individual LSP servers
    -- ----------------------------
    --
    -- configure rust server
    lspconfig["rust_analyzer"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
      cmd = {"/home/mborsali/.cargo/bin/rust-analyzer"},
      settings = {
          ["rust-analyzer"] = {
              cargo = {
                  targetDir = true
              },
              checkOnSave = true,
          }
      }
    })

    -- configure clangd server with plugin
    lspconfig["clangd"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- -- configure python server
    -- lspconfig["pyright"].setup({
    --   capabilities = capabilities,
    --   on_attach = on_attach,
    --   settings = {
    --     pyright = {
    --         -- Using Ruff's import organizer
    --         disableOrganizeImports = true,
    --     },
    --     python = {
    --         analysis = {
    --             -- Ignore all files for analysis to exclusively user Ruff for linting
    --             ignore = { '*' },
    --             typeCheckingMode = "off",
    --         }
    --     },
    --   },
    -- })


    lspconfig["ruff"].setup {
      init_options = {
        settings = {
          lint = {
              -- ignore = {"E4", "E7"}
            ignore = {'E203', -- whitespace before : 
                      'E228', -- space around modulo  
               }
          }
        }
      }
    }

    -- -- configure python server
    -- lspconfig["pylsp"].setup({
    --   capabilities = capabilities,
    --   on_attach = on_attach,
    --   settings = {
    --       pylsp = {
    --           plugins = {
    --               pycodestyle = {
    --               }
    --           }
    --       }
    --   }
    -- })


    -- configure lua server (with special settings)
    lspconfig["lua_ls"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = { -- custom settings for lua
        Lua = {
          -- make the language server recognize "vim" global
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            -- make language server aware of runtime files
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
          },
        },
      },
    })

    vim.lsp.enable("jedi-language-server")
    vim.lsp.config("jedi-language-server", {
      cmd = { "jedi-language-server" },
      filetypes = { "python" },
      root_markers = {
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        "Pipfile",
        ".git",
      }
    })


    -- Show diagnostics in virtual lines
    vim.diagnostic.config({virtual_text = true, virtual_lines = false})

  end,
}
