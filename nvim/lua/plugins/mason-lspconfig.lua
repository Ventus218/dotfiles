-- I use this plugin to ensure installation of my LSs and to enable them automatically

return {
    "mason-org/mason-lspconfig.nvim",
    opts = {
        ensure_installed = {
            -- Lua
            "lua_ls",

            -- Python
            "basedpyright", -- LS
            "ruff", -- Linter + Formatter
        },
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
