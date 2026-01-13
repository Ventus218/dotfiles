-- Set <space> as the leader key
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require("config.lazy")

vim.cmd([[
set number
set relativenumber
set nohls
set scrolloff=7

set smartindent
filetype indent on

set shiftwidth=4
set softtabstop=-1
set expandtab

set splitbelow
set splitright
set winborder=rounded
colorscheme catppuccin
language en_US.UTF-8

nnoremap <C-l> <Esc>
inoremap <C-l> <Esc>
vnoremap <C-l> <Esc>

inoremap <c-space> <c-x><c-o>
]])


-- -- Automatic save
-- vim.o.autowriteall = true
-- vim.api.nvim_create_autocmd({ "InsertLeavePre", "TextChanged", "TextChangedP" }, {
--     pattern = "*", -- save every file
--     callback = function()
--         -- bo: buffer-scoped options
--         if vim.bo.modifiable and not vim.bo.readonly then
--             vim.cmd.update()
--         end
--     end,
-- })

vim.keymap.set("n", "<leader>w", function()
    vim.cmd.write()
end)

-- Inline errors and warnings
vim.diagnostic.config({ virtual_text = true })
-- Show higher severity errors first
vim.diagnostic.config({ severity_sort = true })
