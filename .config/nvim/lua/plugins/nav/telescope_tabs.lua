return {
	'LukasPietzschmann/telescope-tabs',
	config = function()
		require('telescope').load_extension 'telescope-tabs'
		require('telescope-tabs').setup {
            show_preview = true,
		}
    vim.keymap.set("n", "<leader>ttb", "<cmd>Telescope telescope-tabs list_tabs<cr>", { desc = "Find tabs in current project" })
	end,
	dependencies = { 'nvim-telescope/telescope.nvim' },
}
