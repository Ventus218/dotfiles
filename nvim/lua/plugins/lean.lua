---@module 'lean'

-- Automatic restart of file
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*.lean", -- only for lean files
    callback = function(ev)
        -- We check that the file actually has a diagnostic saying the imports are out of date
        for _, d in ipairs(vim.diagnostic.get(ev.buf)) do
            if d.message:find('^Imports are out of date') then
                require("lean.lsp").restart_file(ev.buf)
                break
            end
        end
    end,
})

return {
    'Julian/lean.nvim',
    event = { 'BufReadPre *.lean', 'BufNewFile *.lean' },

    dependencies = {
        -- optional dependencies:

        -- 'nvim-telescope/telescope.nvim', -- for Lean-specific pickers
        -- 'andymass/vim-matchup',          -- for enhanced % motion behavior
        -- 'andrewradev/switch.vim',        -- for switch support
        -- 'tomtom/tcomment_vim',           -- for commenting
    },
    ---@type lean.Config
    opts = { -- see the manual for full configuration options
        mappings = true,

        -- Imports-out-of-date
        on_imports_out_of_date = function(bufnr)
            -- A callback which will be called in the event that a file's imports
            -- have changed and the file must be rebuilt.
            --
            -- See https://github.com/leanprover/vscode-lean4/blob/master/vscode-lean4/manual/manual.md#file-restarting
            -- or the lean.nvim manual for further details.
            --
            -- The default will prompt you to confirm you wish to restart the file,
            -- but you can replace this implementation to customize how to handle
            -- imports being out of date by being either more or less aggressive with
            -- automatic restarting by explicitly calling `lean.lsp.restart_file(bufnr)`.
            require("lean.lsp").restart_file(bufnr)
        end,
    },
}
