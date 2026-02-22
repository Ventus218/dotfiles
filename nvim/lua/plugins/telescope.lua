-- CLI tools required:
-- - fd
-- - ripgrep
return {
    'nvim-telescope/telescope.nvim',
    version = '*',
    dependencies = {
        'nvim-lua/plenary.nvim',
        -- optional but recommended
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    opts = function()
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>t', builtin.builtin, { desc = 'Telescope' })
        vim.keymap.set('n', '<leader>tf', builtin.find_files, { desc = 'Telescope find files' })
        vim.keymap.set('n', '<leader>tg', builtin.live_grep, { desc = 'Telescope live grep' })
        vim.keymap.set('n', '<leader>tb', builtin.buffers, { desc = 'Telescope buffers' })
        vim.keymap.set('n', '<leader>th', builtin.help_tags, { desc = 'Telescope help tags' })

        local actions = require('telescope.actions')
        return {
            defaults = {
                mappings = {
                    i = {
                        ["<C-l>"] = false,
                    },
                    n = {
                        ["<C-l>"] = actions.close,
                    },
                }
            }
        }
    end,
}
