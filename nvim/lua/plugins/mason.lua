local mason_package = "mason-org/mason.nvim"
return {
    {
        mason_package,
        opts = {},
    },
    -- Mason-lspconfig to:
    -- - ensure_installed LSs
    -- - auto enable LSs
    -- We cannot use this to install linters and formatters
    -- as it only accepts name from nvim-lspconfig
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = {
            mason_package,
            "neovim/nvim-lspconfig",
        },
        opts = {
            ensure_installed = {
                -- Lua
                "lua_ls",

                -- Python
                "basedpyright", -- LS
                "ruff",         -- Linter + Formatter (partially an LS)

                -- Shell
                "bashls",

                -- GH Actions
                "gh_actions_ls",
            },
            automatic_enable = true,
        },
    },
    -- Mason-tool-installed to ensure_installed linters and formatters
    -- We could have used this to also ensure_installed LSs but we would
    -- loose automatic enable
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = {
            mason_package,
        },
        opts = {
            ensure_installed = {
                -- Multiple languages
                "prettier", -- Formatter

                -- Shell
                "shellcheck", -- Linter
                "shfmt",      -- Formatter
            },
        },
    }
}
