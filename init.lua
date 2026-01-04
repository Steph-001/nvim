-- >>>>>>>>>>>>>>>>>>>> CONFIGURATION START <<<<<<<<<<<<<<<<<<<<<
-- First, load your custom options (vim.o, vim.g settings)
-- It's usually better to load options before plugins
require("config.options")

-- Now let's load the bootstrap part of lazy.nvim
-- This file should ONLY bootstrap lazy.nvim (install if not present)
-- It should NOT call lazy.setup() itself
require("config.lazy")

-- Now set up lazy.nvim with all your plugins
require("lazy").setup({
    -- == Plugin List ==
    -- Each item here is a plugin specification
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    { "nvimtools/none-ls.nvim" },
    "nvim-tree/nvim-web-devicons",
    
    -- Add oil.nvim with its setup configuration
    {
        "stevearc/oil.nvim",
        config = function()
            require("oil").setup()
        end,
    },
    
    -- == Lazy Options ==
    opts = {
        rocks = {
            enabled = false, -- Disable lazy's LuaRocks management
        }
        -- You could add other lazy.nvim options here if needed
        -- performance = { ... },
        -- ui = { ... },
    }
}) 

-- == LSP Configuration ==
-- Autocommand group for LSP settings upon attaching to a buffer
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        -- Buffer local mappings (only active in the LSP-attached buffer)
        local opts = { buffer = ev.buf }
        -- Keybindings for LSP features
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)           -- Show hover documentation
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)     -- Go to definition
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts) -- Go to implementation
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- Rename symbol
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts) -- Show code actions
        vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { noremap = true, silent = true }) -- Show diagnostics float
    end,
})

-- Markdown file template
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.md",
  callback = function()
    local title = vim.fn.expand("%:t:r")  -- filename without extension
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
    -- Move cursor to inside the brackets in tags: []
    local tag_line = 3  -- zero-indexed in Lua? Actually vim.api is 0-based for lines
    local col = 7       -- position after [
    vim.api.nvim_win_set_cursor(0, {tag_line + 1, col})  -- {line, col}, 1-based line
    -- Enter insert mode
    vim.cmd("startinsert")
  end,
})

-- Notes search with fzf-lua
vim.keymap.set('n', '<leader>fn', function()
  require('fzf-lua').live_grep({ 
    -- Use search_paths instead of cwd to specify multiple directories
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
