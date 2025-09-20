require("config.lazy")

vim.cmd([[
set number
set relativenumber
set scrolloff=7
set winborder=rounded
colorscheme catppuccin
language en_US.UTF-8

nnoremap <C-l> <Esc>
inoremap <C-l> <Esc>
vnoremap <C-l> <Esc>

inoremap <c-space> <c-x><c-o>
]])

-- Inline errors and warnings
vim.diagnostic.config({ virtual_text = true })
-- Show higher severity errors first
vim.diagnostic.config({ severity_sort = true })

