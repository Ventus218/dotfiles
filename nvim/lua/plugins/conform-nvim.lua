return {
    "stevearc/conform.nvim",
    config = function()
        local conform = require("conform")
        conform.setup({
            formatters = {
                -- Here we just prepend some args onto the default shfmt
                -- configuration
                shfmt = {
                    -- We pass the current shiftwidth setting for indentation
                    prepend_args = { "-i", tostring(vim.bo.shiftwidth) }
                },
            },
            formatters_by_ft = {
                -- bash-language-server does not provide range formatting
                -- so we use shfmt as a fallback
                sh = { "shfmt", lsp_format = "first" },
            },
        })
        -- formatexpr is used when typing "gq" and now triggers conform
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
}
