return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "m00qek/baleia.nvim",
    "nvim-telescope/telescope.nvim",
  },
  keys = {
    -- Mnemonic: git status
    { "<Leader>gs", function() require("neogit").open() end, desc = "Neogit status" },
    -- Mnemonic: git commit
    { "<Leader>gc", function() require("neogit").open({ "commit" }) end, desc = "Neogit commit" },
    -- Mnemonic: git log
    { "<Leader>gl", function() require("neogit").open({ "log" }) end, desc = "Neogit log" },
    -- Mnemonic: git diff
    { "<Leader>gd", function() require("neogit").open({ "diff" }) end, desc = "Neogit diff" },
  },
  opts = {
    -- Use default keymaps for all neogit buffers
    use_default_keymaps = true,
    -- Show hint line at top of status buffer
    disable_hint = false,
    -- Highlight context based on cursor position
    disable_context_highlighting = false,
    -- Show special signs for sections
    disable_signs = false,
    -- Treesitter-based syntax highlighting for diff hunks
    treesitter_diff_highlight = false,
    -- Highlight word-level changes in diff hunks
    word_diff_highlight = true,
    -- Ask before force pushing
    prompt_force_push = true,
    -- Ask before amending a commit
    prompt_amend_commit = true,
    -- Graph style for log view
    graph_style = "ascii",
    -- Date format for commits (nil = default)
    commit_date_format = nil,
    -- Date format for log view (nil = default)
    log_date_format = nil,
    -- External pager for log (nil = internal)
    log_pager = nil,
    -- Show spinner for git processes
    process_spinner = false,
    -- Watch filesystem for changes
    filewatcher = {
      enabled = true,
    },
    -- Git hosting services for "open in browser" links
    git_services = {
      ["github.com"] = {
        pull_request = "https://github.com/${owner}/${repository}/compare/${branch_name}?expand=1",
        commit = "https://github.com/${owner}/${repository}/commit/${oid}",
        tree = "https://${host}/${owner}/${repository}/tree/${branch_name}",
      },
      ["bitbucket.org"] = {
        pull_request = "https://bitbucket.org/${owner}/${repository}/pull-requests/new?source=${branch_name}&t=1",
        commit = "https://bitbucket.org/${owner}/${repository}/commits/${oid}",
        tree = "https://bitbucket.org/${owner}/${repository}/branch/${branch_name}",
      },
      ["gitlab.com"] = {
        pull_request = "https://gitlab.com/${owner}/${repository}/merge_requests/new?merge_request[source_branch]=${branch_name}",
        commit = "https://gitlab.com/${owner}/${repository}/-/commit/${oid}",
        tree = "https://gitlab.com/${owner}/${repository}/-/tree/${branch_name}?ref_type=heads",
      },
      ["azure.com"] = {
        pull_request = "https://dev.azure.com/${owner}/_git/${repository}/pullrequestcreate?sourceRef=${branch_name}&targetRef=${target}",
        commit = "",
        tree = "",
      },
      ["codeberg.org"] = {
        pull_request = "https://${host}/${owner}/${repository}/compare/${branch_name}",
        commit = "https://${host}/${owner}/${repository}/commit/${oid}",
        tree = "https://${host}/${owner}/${repository}/src/branch/${branch_name}",
      },
    },
    -- Highlight overrides
    highlight = {},
    -- Git binary path
    git_executable = "git",
    -- Don't auto-enter insert mode in commit editor ("auto" = only on new commits)
    disable_insert_on_commit = "auto",
    -- Remember popup settings per project
    use_per_project_settings = true,
    remember_settings = true,
    -- Don't fetch after checking out a branch
    fetch_after_checkout = false,
    -- Sort branches by most recent commit
    sort_branches = "-committerdate",
    -- Commit ordering: empty string = git default (date order), avoids expensive
    -- topological sorting in large repos (1.5s → 0.09s in monolith)
    commit_order = "",
    -- Open neogit in a new tab
    kind = "tab",
    -- Floating window dimensions
    floating = {
      relative = "editor",
      width = 0.8,
      height = 0.7,
      style = "minimal",
      border = "rounded",
    },
    -- Default branch name for new repos
    initial_branch_name = "",
    -- Hide line numbers in neogit buffers
    disable_line_numbers = true,
    disable_relative_line_numbers = true,
    -- Show console for commands slower than this (ms)
    console_timeout = 2000,
    auto_show_console = true,
    -- "output" = always, "error" = only on error
    auto_show_console_on = "output",
    auto_close_console = true,
    -- Icon in notifications
    notification_icon = "󰊢",
    -- Status buffer options
    status = {
      show_head_commit_hash = true,
      recent_commit_count = 10,
      HEAD_padding = 10,
      HEAD_folded = false,
      mode_padding = 3,
      mode_text = {
        M = "modified",
        N = "new file",
        A = "added",
        D = "deleted",
        C = "copied",
        U = "updated",
        R = "renamed",
        T = "changed",
        DD = "unmerged",
        AU = "unmerged",
        UD = "unmerged",
        UA = "unmerged",
        DU = "unmerged",
        AA = "unmerged",
        UU = "unmerged",
        ["?"] = "",
      },
    },
    -- Commit editor options
    commit_editor = {
      kind = "tab",
      show_staged_diff = true,
      staged_diff_split_kind = "split",
      spell_check = true,
    },
    commit_select_view = {
      kind = "tab",
    },
    commit_view = {
      kind = "vsplit",
      verify_commit = vim.fn.executable("gpg") == 1,
    },
    log_view = {
      kind = "tab",
    },
    rebase_editor = {
      kind = "auto",
    },
    reflog_view = {
      kind = "tab",
    },
    merge_editor = {
      kind = "auto",
    },
    preview_buffer = {
      kind = "floating_console",
    },
    popup = {
      kind = "split",
    },
    stash = {
      kind = "tab",
    },
    refs_view = {
      kind = "tab",
    },
    -- Icons for toggling sections/items/hunks
    signs = {
      hunk = { "", "" },
      item = { ">", "v" },
      section = { ">", "v" },
    },
    -- Plugin integrations
    integrations = {
      telescope = true,
      diffview = true,
      codediff = nil,
      fzf_lua = nil,
      mini_pick = nil,
      snacks = nil,
    },
    -- nil = auto-detect based on integrations
    diff_viewer = nil,
    -- Sections in the status buffer
    -- Hidden sections are skipped entirely (saves git commands in large repos)
    sections = {
      sequencer = {
        folded = false,
        hidden = false,
      },
      bisect = {
        folded = false,
        hidden = false,
      },
      untracked = {
        folded = false,
        hidden = false,
      },
      unstaged = {
        folded = false,
        hidden = false,
      },
      staged = {
        folded = false,
        hidden = false,
      },
      stashes = {
        folded = true,
        hidden = false,
      },
      -- Hidden: slow in large repos (compares with upstream)
      unpulled_upstream = {
        folded = true,
        hidden = false,
      },
      unmerged_upstream = {
        folded = false,
        hidden = false,
      },
      -- Hidden: slow in large repos (compares with pushRemote)
      unpulled_pushRemote = {
        folded = true,
        hidden = false,
      },
      unmerged_pushRemote = {
        folded = false,
        hidden = false,
      },
      -- Recent commits section
      recent = {
        folded = true,
        hidden = false,
      },
      rebase = {
        folded = true,
        hidden = false,
      },
    },
    -- Settings to never persist (format: "Filetype--cli-value")
    ignored_settings = {},
    -- Keymaps for all neogit buffer types
    mappings = {
      commit_view = {
        ["a"] = "OpenFileInWorktree",
        ["o"] = "OpenCommitLinkInBrowser",
      },
      commit_editor = {
        ["q"] = "Close",
        ["<c-c><c-c>"] = "Submit",
        ["<c-c><c-k>"] = "Abort",
        ["<m-p>"] = "PrevMessage",
        ["<m-n>"] = "NextMessage",
        ["<m-r>"] = "ResetMessage",
      },
      commit_editor_I = {
        ["<c-c><c-c>"] = "Submit",
        ["<c-c><c-k>"] = "Abort",
      },
      rebase_editor = {
        ["p"] = "Pick",
        ["r"] = "Reword",
        ["e"] = "Edit",
        ["s"] = "Squash",
        ["f"] = "Fixup",
        ["x"] = "Execute",
        ["d"] = "Drop",
        ["b"] = "Break",
        ["q"] = "Close",
        ["<cr>"] = "OpenCommit",
        ["gk"] = "MoveUp",
        ["gj"] = "MoveDown",
        ["<c-c><c-c>"] = "Submit",
        ["<c-c><c-k>"] = "Abort",
        ["[c"] = "OpenOrScrollUp",
        ["]c"] = "OpenOrScrollDown",
      },
      rebase_editor_I = {
        ["<c-c><c-c>"] = "Submit",
        ["<c-c><c-k>"] = "Abort",
      },
      finder = {
        ["<cr>"] = "Select",
        ["<c-c>"] = "Close",
        ["<esc>"] = "Close",
        ["<c-n>"] = "Next",
        ["<c-p>"] = "Previous",
        ["<down>"] = "Next",
        ["<up>"] = "Previous",
        ["<tab>"] = "InsertCompletion",
        ["<c-y>"] = "CopySelection",
        ["<space>"] = "MultiselectToggleNext",
        ["<s-space>"] = "MultiselectTogglePrevious",
        ["<c-j>"] = "NOP",
        ["<ScrollWheelDown>"] = "ScrollWheelDown",
        ["<ScrollWheelUp>"] = "ScrollWheelUp",
        ["<ScrollWheelLeft>"] = "NOP",
        ["<ScrollWheelRight>"] = "NOP",
        ["<LeftMouse>"] = "MouseClick",
        ["<2-LeftMouse>"] = "NOP",
      },
      refs_view = {
        ["x"] = "DeleteBranch",
      },
      popup = {
        ["?"] = "HelpPopup",
        ["A"] = "CherryPickPopup",
        ["d"] = "DiffPopup",
        ["M"] = "RemotePopup",
        ["P"] = "PushPopup",
        ["X"] = "ResetPopup",
        ["Z"] = "StashPopup",
        ["i"] = "IgnorePopup",
        ["t"] = "TagPopup",
        ["b"] = "BranchPopup",
        ["B"] = "BisectPopup",
        ["w"] = "WorktreePopup",
        ["c"] = "CommitPopup",
        ["f"] = "FetchPopup",
        ["l"] = "LogPopup",
        ["L"] = "MarginPopup",
        ["m"] = "MergePopup",
        ["p"] = "PullPopup",
        ["r"] = "RebasePopup",
        ["v"] = "RevertPopup",
      },
      status = {
        ["j"] = "MoveDown",
        ["k"] = "MoveUp",
        ["o"] = "OpenTree",
        ["q"] = "Close",
        ["I"] = "InitRepo",
        ["1"] = "Depth1",
        ["2"] = "Depth2",
        ["3"] = "Depth3",
        ["4"] = "Depth4",
        ["Q"] = "Command",
        ["<tab>"] = "Toggle",
        ["za"] = "Toggle",
        ["zo"] = "OpenFold",
        ["zc"] = "CloseFold",
        ["zC"] = "Depth1",
        ["zO"] = "Depth4",
        ["x"] = "Discard",
        ["-"] = "Reverse",
        ["s"] = "Stage",
        ["S"] = "StageUnstaged",
        ["<c-s>"] = "StageAll",
        ["u"] = "Unstage",
        ["K"] = "Untrack",
        ["R"] = "Rename",
        ["U"] = "UnstageStaged",
        ["y"] = "ShowRefs",
        ["$"] = "CommandHistory",
        ["Y"] = "YankSelected",
        ["gp"] = "GoToParentRepo",
        ["<c-r>"] = "RefreshBuffer",
        ["<cr>"] = "GoToFile",
        ["<s-cr>"] = "PeekFile",
        ["<c-v>"] = "VSplitOpen",
        ["<c-x>"] = "SplitOpen",
        ["<c-t>"] = "TabOpen",
        ["{"] = "GoToPreviousHunkHeader",
        ["}"] = "GoToNextHunkHeader",
        ["[c"] = "OpenOrScrollUp",
        ["]c"] = "OpenOrScrollDown",
        ["<c-k>"] = "PeekUp",
        ["<c-j>"] = "PeekDown",
        ["<c-n>"] = "NextSection",
        ["<c-p>"] = "PreviousSection",
      },
    },
  },
}
