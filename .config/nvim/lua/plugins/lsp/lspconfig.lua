return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  config = function()
    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    -- disable logging to avoid log file to grow indefinitely
    -- TODO: remove 0.11 branch once fully migrated to 0.12 (summer 2026)
    if vim.fn.has("nvim-0.12") == 1 then
      -- 0.12+: vim.lsp.set_log_level() is deprecated
      vim.lsp.log.set_level("off")
    else
      vim.lsp.set_log_level("off")
    end

    local keymap = vim.keymap -- for conciseness

    -- Register LSP keybindings via LspAttach autocmd.
    -- vim.lsp.config() does not support on_attach (that was nvim-lspconfig's
    -- .setup() feature), so we use neovim's native event instead.
    local diagnostics_active = true
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(ev)
        local opts = { noremap = true, silent = true, buffer = ev.buf }

        opts.desc = "LSP: show references"
        keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

        opts.desc = "LSP: go to declaration"
        keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

        opts.desc = "LSP: show definitions"
        keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

        opts.desc = "LSP: show implementations"
        keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

        opts.desc = "LSP: type definitions"
        keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

        opts.desc = "LSP: See available code actions"
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

        opts.desc = "LSP: Smart rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

        opts.desc = "Show buffer diagnostics (Telescope)"
        keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

        -- Mnemonic: ds=show, dn=next, dp=prev, dt=toggle
        opts.desc = "Show line diagnostics"
        keymap.set("n", "<leader>ds", vim.diagnostic.open_float, opts)

        opts.desc = "Go to next diagnostic"
        keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, opts)

        opts.desc = "Go to previous diagnostic"
        keymap.set("n", "<leader>dp", vim.diagnostic.goto_prev, opts)

        opts.desc = "Toggle diagnostics on/off"
        keymap.set("n", "<leader>dt", function()
          diagnostics_active = not diagnostics_active
          vim.diagnostic.enable(diagnostics_active)
        end, opts)

        opts.desc = "Show documentation for what is under cursor"
        keymap.set("n", "<leader>k", vim.lsp.buf.hover, opts)

        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
      end
    })

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Diagnostic signs are configured in nav/neo_tree.lua via vim.diagnostic.config()

    -- ----------------------------
    -- Setup individual LSP servers
    -- ----------------------------

    -- configure rust server
    vim.lsp.config("rust_analyzer", {
      capabilities = capabilities,
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

    -- configure clangd server
    vim.lsp.config("clangd", {
      capabilities = capabilities,
    })

    -- configure ruff (python linter)
    vim.lsp.config("ruff", {
      init_options = {
        settings = {
          configuration = {
            lint = {
              ignore = {'E203', -- whitespace before :
                        'E228', -- space around modulo
                        'E402', -- module import not at top of file
                     }
            }
          }
        }
      }
    })

    -- NOTE: pylsp is commented out. If it's installed (via Mason or system-wide),
    -- Neovim 0.11+ may auto-detect and start it from PATH without an explicit
    -- setup call. If pylsp appears in :LspInfo unexpectedly, uninstall it with
    -- :MasonUninstall python-lsp-server (or remove it from PATH).

    -- configure lua server (with special settings)
    vim.lsp.config("lua_ls", {
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
          },
        },
      },
    })

    -- configure jedi (python intellisense)
    -- .git is intentionally excluded from root_markers to prevent jedi from
    -- using the monolith git root as workspace and indexing the entire repo
    vim.lsp.config("jedi-language-server", {
      cmd = { vim.fn.stdpath("data") .. "/mason/bin/jedi-language-server" },
      filetypes = { "python" },
      root_markers = {
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        "Pipfile",
      }
    })

    -- Enable all configured servers
    vim.lsp.enable({
      "rust_analyzer",
      "clangd",
      "ruff",
      "lua_ls",
      "jedi-language-server",
    })

    -- Show diagnostics in virtual text.
    -- Sign icons are configured in neo_tree.lua via vim.diagnostic.config().
    vim.diagnostic.config({
      virtual_text = true,
      virtual_lines = false,
      severity_sort = true,
    })

    -- TODO: remove these commands once fully migrated to 0.12 (summer 2026)
    -- In 0.12 with native vim.lsp.config()/enable(), nvim-lspconfig no longer
    -- provides :LspRestart/:LspStop/:LspInfo, so we define our own.
    if vim.fn.has("nvim-0.12") == 1 then
      vim.api.nvim_create_user_command("LspStop", function()
        for _, client in ipairs(vim.lsp.get_clients()) do
          client:stop()
        end
      end, { desc = "Stop all LSP clients" })

      vim.api.nvim_create_user_command("LspRestart", function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        for _, client in ipairs(clients) do
          local names = { client.name }
          client:stop()
          vim.defer_fn(function()
            for _, name in ipairs(names) do
              vim.lsp.enable(name)
            end
          end, 500)
        end
      end, { desc = "Restart LSP clients for current buffer" })

      vim.api.nvim_create_user_command("LspInfo", function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients == 0 then
          print("No LSP clients attached")
          return
        end
        for _, client in ipairs(clients) do
          print(string.format("%s (id=%d) root=%s", client.name, client.id, client.root_dir or "none"))
        end
      end, { desc = "Show LSP clients for current buffer" })
    end

  end,
}
