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

        -- Find the nnn terminal buffer channel.
        local function get_nnn_chan()
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "nnn" then
                    local chan = vim.bo[buf].channel
                    if chan and chan > 0 then return chan end
                end
            end
            return nil
        end

        local cfg = {
          explorer = {
            cmd = "nnn",       -- command override (-F1 flag is implied by nnn.nvim)
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
          },
          buflisted = false,   -- whether or not nnn buffers show up in the bufferlist
          quitcd = nil,        -- or "cd" / tcd" / "lcd", command to run on quitcd file if found
          offset = false,      -- whether or not to write position offset to tmpfile(for use in preview-tui)
        }
        nnn.setup(cfg)

        -- Ctrl+b (in nnn): cd nvim to nnn's current directory
        -- Mnemonic: browse here
        -- Ctrl+d (in nnn): show nnn's current directory as notification
        -- Mnemonic: directory
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "nnn",
            callback = function()
                vim.keymap.set("t", "<C-b>", function()
                    cd_to_nnn_cwd()
                    vim.cmd("startinsert")
                end, { buffer = true })

                vim.keymap.set("t", "<C-d>", function()
                    local buf = vim.api.nvim_get_current_buf()
                    local chan = vim.bo[buf].channel
                    if chan and chan > 0 then
                        local pid = vim.fn.jobpid(chan)
                        local cwd = vim.loop.fs_readlink("/proc/" .. pid .. "/cwd")
                        if cwd then
                            vim.notify(cwd)
                        end
                    end
                    vim.cmd("startinsert")
                end, { buffer = true })
            end,
        })

        -- <Leader>nf: focus the nnn pane from any window (opens it if closed).
        -- Mnemonic: nnn focus
        vim.keymap.set("n", "<Leader>nf", function()
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                local buf = vim.api.nvim_win_get_buf(win)
                if vim.bo[buf].filetype == "nnn" then
                    vim.api.nvim_set_current_win(win)
                    vim.cmd("startinsert")
                    return
                end
            end
            -- nnn not open — open it
            nnn.toggle("explorer")
        end, { desc = "nnn: focus pane" })

        -- <Leader>ns: navigate nnn to current file's directory.
        -- Mnemonic: nnn sync
        -- Writes the target path to /tmp/nnn-goto then triggers the "nvimcd"
        -- plugin (;n) via chansend. The plugin reads the path and calls nnn_cd
        -- to navigate nnn in the current context.
        vim.keymap.set("n", "<Leader>ns", function()
            local dir = vim.fn.expand("%:p:h")
            if dir == "" then
                vim.notify("Buffer has no file")
                return
            end
            local chan = get_nnn_chan()
            if not chan then
                vim.notify("nnn not running")
                return
            end
            -- Write target dir to the file the nvimcd plugin reads
            local f = io.open("/tmp/nnn-goto", "w")
            if not f then
                vim.notify("Failed to write /tmp/nnn-goto")
                return
            end
            f:write(dir)
            f:close()
            -- Trigger the nvimcd plugin: ; enters plugin mode, n selects it
            vim.fn.chansend(chan, ";n")
            vim.notify("nnn → " .. dir)
        end, { desc = "nnn: sync to file dir" })
    end
}

