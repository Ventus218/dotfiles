return {
    "mfussenegger/nvim-lint",
    event = {
        "BufReadPre",
        "BufNewFile",
    },
    config = function()
        local lint = require("lint")
        lint.linters_by_ft = {
            -- Shellcheck is run automatically by bash-language-server,
            -- it is here just as example for future entries
            -- sh = { "shellcheck" },
        }

        local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

        -- TODO: triggering events may be adjusted
        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "TextChanged" }, {
            group = lint_augroup,
            callback = function()
                lint.try_lint()
            end,
        })
    end,
}
