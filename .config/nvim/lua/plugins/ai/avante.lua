--- Read the API key from Claude Code's OAuth-managed config.
--- The key is generated during `claude` SSO login and stored in ~/.claude.json.
local function get_claude_api_key()
    local path = vim.fn.expand("~/.claude.json")
    local f = io.open(path, "r")
    if not f then return nil end
    local content = f:read("*a")
    f:close()
    local key = content:match('"primaryApiKey"%s*:%s*"(sk%-ant%-[^"]+)"')
    return key
end

return {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    build = "make",
    opts = {
        provider = "claude",
        providers = {
            claude = {
                api_key_name = { "echo", get_claude_api_key() },
                model = "claude-haiku-4-5-20251001",
                extra_request_body = {
                    max_tokens = 4096,
                },
            },
        },
        -- Keybindings: <Leader>a = AI, a = avante, then action
        mappings = {
            ask = "<Leader>aaa",       -- ai avante ask
            edit = "<Leader>aae",      -- ai avante edit
            refresh = "<Leader>aar",   -- ai avante refresh
            toggle = {
                default = "<Leader>aat", -- ai avante toggle
            },
            focus = "<Leader>aaf",     -- ai avante focus
        },
    },
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "echasnovski/mini.icons",
    },
}
