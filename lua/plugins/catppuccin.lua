return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
        local transparency_enabled = true 
        
        _G.toggle_transparency = function()
            transparency_enabled = not transparency_enabled
            require("catppuccin").setup({
                transparent_background = transparency_enabled,
                custom_highlights = function(colors)
                    return {
                        ["@markup.link.url.markdown_inline"] = { link = "Special" },
                        ["@markup.link.label.markdown_inline"] = { link = "WarningMsg" },
                        ["@markup.italic.markdown_inline"] = { link = "Exception" },
                        ["@markup.raw.markdown_inline"] = { link = "String" },
                        ["@markup.list.markdown"] = { link = "Function" },
                        ["@markup.quote.markdown"] = { link = "Error" },
                        ["@markup.list.checked.markdown"] = { link = "WarningMsg" }
                    }
                end
            })
            vim.cmd("colorscheme catppuccin")
            print("Transparency " .. (transparency_enabled and "enabled" or "disabled"))
        end
        
        require("catppuccin").setup({
            transparent_background = transparency_enabled,
            custom_highlights = function(colors)
                return {
                    ["@markup.link.url.markdown_inline"] = { link = "Special" },
                    ["@markup.link.label.markdown_inline"] = { link = "WarningMsg" },
                    ["@markup.italic.markdown_inline"] = { link = "Exception" },
                    ["@markup.raw.markdown_inline"] = { link = "String" },
                    ["@markup.list.markdown"] = { link = "Function" },
                    ["@markup.quote.markdown"] = { link = "Error" },
                    ["@markup.list.checked.markdown"] = { link = "WarningMsg" }
                }
            end
        })
        vim.cmd("colorscheme catppuccin")
    end,
}
