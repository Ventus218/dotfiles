return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = 'main',
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require('nvim-treesitter').setup {
                -- Directory to install parsers and queries to (prepended to `runtimepath` to have priority)
                install_dir = vim.fn.stdpath('data') .. '/site'
            }
            require('nvim-treesitter').install { "lua", "vim", "vimdoc", "markdown", "markdown_inline", "scala", "java", "javascript", "bash", "dockerfile" }

            -- Automatic install of missing parser and treesitter.start which starts highlighting
            vim.api.nvim_create_autocmd('FileType', {
                callback = function(ev)
                    local lang = vim.treesitter.language.get_lang(ev.match)
                    local available_langs = require('nvim-treesitter').get_available()
                    local is_available = vim.tbl_contains(available_langs, lang)
                    if is_available then
                        local installed_langs = require('nvim-treesitter').get_installed()
                        local installed = vim.tbl_contains(installed_langs, lang)
                        if not installed then
                            vim.notify("Installing " .. lang .. " parser", vim.log.levels.INFO,
                                { title = "nvim-treesitter" })
                            require('nvim-treesitter').install(lang):wait()
                            vim.notify(lang .. " parser installed!", vim.log.levels.INFO, { title = "nvim-treesitter" })
                        end
                        vim.treesitter.start()
                        require('nvim-treesitter').indentexpr() -- Do i need this??
                    end
                end,
            })
        end
    }
}
