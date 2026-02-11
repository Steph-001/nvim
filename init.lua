-- >>>>>>>>>>>>>>>>>>>> CONFIGURATION START <<<<<<<<<<<<<<<<<<<
-- First, load your custom options (vim.o, vim.g settings)
require("config.options")

-- Bootstrap lazy.nvim (this just installs it, doesn't load plugins yet)
require("config.lazy")

-- Now set up lazy.nvim with all your plugins
require("lazy").setup({
    spec = {
        -- Import all plugins from lua/plugins/*.lua
        { import = "plugins" },
    },
    install = { colorscheme = { "catppuccin" } },
    checker = { enabled = true },
})

-- == LSP Configuration ==
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        local opts = { buffer = ev.buf }
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { noremap = true, silent = true })
    end,
})

-- Markdown file template
vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = "*.md",
    callback = function()
        local title = vim.fn.expand("%:t:r")
        local date = os.date("%Y-%m-%d")
        local lines = {
            "---",
            'title: "' .. title:gsub("-", " ") .. '"',
            "date: " .. date,
            "tags: []",
            "---",
            "",
            "# " .. title:gsub("-", " "),
            ""
        }
        vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
        local tag_line = 3
        local col = 7
        vim.api.nvim_win_set_cursor(0, {tag_line + 1, col})
        vim.cmd("startinsert")
    end,
})

-- Notes search with fzf-lua
vim.keymap.set('n', '<leader>fn', function()
    require('fzf-lua').live_grep({ 
        search_paths = {
            '/mnt/c/Users/steph/OneDrive - Région Île-de-France/nts',
            '~/notes',
        }
    })
end, { desc = 'Search in all note folders' })

-- Do not treat csv files as code
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = "*.csv",
    command = "setlocal syntax=off"
})

vim.opt.clipboard = "unnamedplus"

-- Load keymaps last
require("config.keymaps")
