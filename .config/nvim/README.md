# Neovim Configuration

## NNN File Explorer

Bidirectional directory sync between neovim and nnn via [nnn.nvim](https://github.com/luukvbaal/nnn.nvim).

### Keybindings

| Key | Context | Action | Mnemonic |
|-----|---------|--------|----------|
| `<C-b>` | nnn terminal | cd neovim to nnn's current directory | **b**rowse here |
| `<Leader>nf` | normal buffer | navigate nnn to current file's directory | **n**nn **f**ollow |
| `<Leader>ng` | normal buffer | jump to nnn pane (opens it if closed) | **n**nn **g**o |

### How `<Leader>nf` works

1. Neovim writes the current buffer's parent directory to `/tmp/nnn-goto`
2. Sends `;n` to the nnn terminal via `chansend`, triggering the `nvimcd` plugin
3. The plugin reads the path and calls `nnn_cd` to navigate nnn in the current context
4. nnn state (tabs, selections, etc.) is fully preserved

### Files involved

| File | Role |
|------|------|
| `~/.config/nvim/lua/plugins/nav/nnn.lua` | Plugin config, keybindings, helper functions |
| `~/.config/nnn/plugins/nvimcd` | nnn plugin that reads `/tmp/nnn-goto` and calls `nnn_cd` |
| `~/.nnn.bash` | Exports `NNN_PLUG` with `n:nvimcd` registered |
| `~/.config/nnn/plugins/.nnn-plugin-helper` | Provides `nnn_cd` (writes `0c<path>` to `NNN_PIPE`) |

### How `<C-b>` works

Reads the nnn process's current working directory from `/proc/<pid>/cwd` via
`vim.fn.jobpid()` and `vim.loop.fs_readlink()`. This bypasses nnn's mapping
system entirely (set via a neovim `FileType` autocmd on the nnn buffer).
