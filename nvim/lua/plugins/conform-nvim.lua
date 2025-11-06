return {
    "stevearc/conform.nvim",
    config = function()
        local conform = require("conform")
        conform.setup({
            formatters = {
                shfmt = {
                    -- We pass the current shiftwidth setting for indentation
                    prepend_args = { "-i", tostring(vim.bo.shiftwidth) }
                },
                prettier = {
                    prepend_args = { "--prose-wrap", "always" }
                },
            },
            formatters_by_ft = {
                sh = { "shfmt" },
                yaml = { "prettier" },
                markdown = { "prettier" },
            },
            -- We generally prioritize the lsp formatter and use these as fallbacks
            default_format_opts = { lsp_format = "first" },
            format_on_save = {},
        })
        -- formatexpr is used when typing "gq" and now triggers conform
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
}
