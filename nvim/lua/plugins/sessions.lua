return {
	"rmagatti/auto-session",
	lazy = false, -- Sessions should load immediately
	dependencies = {
		"nvim-telescope/telescope.nvim", -- Required for the session picker
	},
	config = function()
		require("auto-session").setup({
			auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
			-- Session lens is now configured inside the main setup
			session_lens = {
				buftypes_to_ignore = {},
				load_on_setup = true,
				theme_conf = { border = true },
				previewer = false,
			},
		})

		-- Fixed Keymap: Uses the new command and avoids the require error
		vim.keymap.set("n", "<leader>ls", "<cmd>AutoSession search<CR>", {
			noremap = true,
			desc = "Search sessions",
		})
	end,
}
