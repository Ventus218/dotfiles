-- I use this plugin to ensure installation of my LSs and to enable them automatically

return {
	"mason-org/mason-lspconfig.nvim",
	opts = {
		automatic_enable = true,
	},
	dependencies = {
		{
			"mason-org/mason.nvim",
			opts = {},
		},
		"neovim/nvim-lspconfig",
	},
}

