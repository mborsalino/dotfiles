-- On-demand named session management using built-in :mksession.
-- No auto-save — sessions are saved and loaded explicitly via keybindings.
--
-- <Leader>sss  Save session (prompts for a name)
-- <Leader>ssl  Load session (fzf picker from saved sessions)
-- <Leader>ssd  Delete session (fzf picker)
--
-- Sessions are stored in ~/.config/nvim/sessions/<name>.vim
-- Only buffers, splits, cursor positions, and folds are saved (no terminals).

local session_dir = vim.fn.stdpath("config") .. "/sessions"

-- Ensure session directory exists
vim.fn.mkdir(session_dir, "p")

-- Save only what matters: buffers, splits, cursor, folds, cwd
vim.o.sessionoptions = "buffers,curdir,folds,tabpages,winsize"

-- Save session: prompts for a name, defaults to "default"
vim.keymap.set("n", "<Leader>sss", function()
    vim.ui.input({ prompt = "Session name: ", default = "default" }, function(name)
        if not name or name == "" then return end
        local path = session_dir .. "/" .. name .. ".vim"
        vim.cmd("mksession! " .. vim.fn.fnameescape(path))
        vim.notify("Session saved: " .. name)
    end)
end, { desc = "Session: save" })

-- Load session: picker from saved sessions
vim.keymap.set("n", "<Leader>ssl", function()
    local sessions = vim.fn.globpath(session_dir, "*.vim", false, true)
    if #sessions == 0 then
        vim.notify("No saved sessions")
        return
    end
    local names = {}
    for _, s in ipairs(sessions) do
        table.insert(names, vim.fn.fnamemodify(s, ":t:r"))
    end
    vim.ui.select(names, { prompt = "Load session:" }, function(choice)
        if not choice then return end
        local path = session_dir .. "/" .. choice .. ".vim"
        vim.cmd("silent! %bdelete")
        vim.cmd("source " .. vim.fn.fnameescape(path))
        vim.notify("Session loaded: " .. choice)
    end)
end, { desc = "Session: load" })

-- Delete session: picker from saved sessions
vim.keymap.set("n", "<Leader>ssd", function()
    local sessions = vim.fn.globpath(session_dir, "*.vim", false, true)
    if #sessions == 0 then
        vim.notify("No saved sessions")
        return
    end
    local names = {}
    for _, s in ipairs(sessions) do
        table.insert(names, vim.fn.fnamemodify(s, ":t:r"))
    end
    vim.ui.select(names, { prompt = "Delete session:" }, function(choice)
        if not choice then return end
        local path = session_dir .. "/" .. choice .. ".vim"
        os.remove(path)
        vim.notify("Session deleted: " .. choice)
    end)
end, { desc = "Session: delete" })

return {}
