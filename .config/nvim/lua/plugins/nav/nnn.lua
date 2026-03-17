return {
    "luukvbaal/nnn.nvim",
    config = function()
        local nnn = require("nnn")
        local builtin = require("nnn").builtin

        -- cd nvim to nnn's current directory by reading /proc/<pid>/cwd
        -- Works on both files and directories (bypasses nnn's Enter handling)
        local function cd_to_nnn_cwd()
            local buf = vim.api.nvim_get_current_buf()
            local chan = vim.bo[buf].channel
            if chan and chan > 0 then
                local pid = vim.fn.jobpid(chan)
                local cwd = vim.loop.fs_readlink("/proc/" .. pid .. "/cwd")
                if cwd then
                    vim.cmd("cd " .. vim.fn.fnameescape(cwd))
                    vim.defer_fn(function() vim.notify("pwd: " .. cwd) end, 100)
                end
            end
        end

        local cfg = {
          explorer = {
            cmd = "nnn",       -- command override (-F1 flag is implied, -a flag is invalid!)
            width = 24,        -- width of the vertical split
            side = "topleft",  -- or "botright", location of the explorer window
            session = "",      -- or "global" / "local" / "shared"
            tabs = true,       -- separate nnn instance per tab
            fullscreen = false, -- always open as side panel, even on empty tab
          },
          picker = {
            cmd = "nnn",       -- command override (-p flag is implied)
            style = {
              width = 0.9,     -- percentage relative to terminal size when < 1, absolute otherwise
              height = 0.8,    -- ^
              xoffset = 0.5,   -- ^
              yoffset = 0.5,   -- ^
              border = "single"-- border decoration for example "rounded"(:h nvim_open_win)
            },
            session = "",      -- or "global" / "local" / "shared"
            tabs = true,       -- separate nnn instance per tab
            fullscreen = true, -- whether to fullscreen picker window when current tab is empty
          },
          auto_open = {
            setup = nil,       -- or "explorer" / "picker", auto open on setup function
            tabpage = nil,     -- or "explorer" / "picker", auto open when opening new tabpage
            empty = false,     -- only auto open on empty buffer
            ft_ignore = {      -- dont auto open for these filetypes
              "gitcommit",
            }
          },
          auto_close = true,  -- close tabpage/nvim when nnn is last window
          replace_netrw = nil, -- or "explorer" / "picker"
          mappings = {
            { "<C-t>", builtin.open_in_tab },       -- open file(s) in tab
            { "<C-S>", builtin.open_in_split },     -- open file(s) in split
            { "<C-s>", builtin.open_in_vsplit },    -- open file(s) in vertical split
            { "<C-p>", builtin.open_in_preview },   -- open file in preview split keeping nnn focused
            { "<C-y>", builtin.copy_to_clipboard }, -- copy file(s) to clipboard
            { "<C-e>", builtin.populate_cmdline },  -- populate cmdline (:) with file(s)
          },       -- table containing mappings
          windownav = {        -- window movement mappings to navigate out of nnn
            left = "<C-h>",
            right = "<C-l>",
            next = false,      -- disabled: conflicts with <C-w> cd_to_path mapping
            prev = false,      -- disabled: conflicts with <C-w> cd_to_path mapping
          },
          buflisted = false,   -- whether or not nnn buffers show up in the bufferlist
          quitcd = nil,        -- or "cd" / tcd" / "lcd", command to run on quitcd file if found
          offset = false,      -- whether or not to write position offset to tmpfile(for use in preview-tui)
        }
        nnn.setup(cfg)

        -- Ctrl+b: cd nvim to nnn's current directory ("browse here" / "base dir")
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "nnn",
            callback = function()
                vim.keymap.set("t", "<C-b>", function()
                    cd_to_nnn_cwd()
                    vim.cmd("startinsert")
                end, { buffer = true })
            end,
        })
    end
}

