return {
    "obsidian-nvim/obsidian.nvim",
    version = "*", -- use latest release, remove to use latest commit
    -- Do not start this plugin if not in an obsidian vault
    cond = function()
        return vim.fs.root(0, ".obsidian") ~= nil
    end,
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
        legacy_commands = false, -- this will be removed in 4.0.0
        workspaces = {
            {
                name = "current_vault",
                path = function()
                    local root = vim.fs.root(0, ".obsidian")
                    return root or vim.fn.getcwd()
                end,
            },
        },
    },
}
