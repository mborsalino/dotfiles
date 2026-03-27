return {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "VeryLazy",
    init = function()
        -- Required vim options for ufo to manage folds
        vim.o.foldcolumn = "0"  -- hide fold gutter (ufo works without it)
        vim.o.foldlevel = 99      -- start with all folds open
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true
        vim.o.foldnestmax = 2     -- only fold 2 levels deep (module → class → method)
    end,
    opts = {
        -- Use treesitter as primary fold provider, indent as fallback
        provider_selector = function()
            return { "treesitter", "indent" }
        end,
        -- Show first line of folded block as virtual text preview
        fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
            local newVirtText = {}
            local suffix = ("  %d lines "):format(endLnum - lnum)
            local sufWidth = vim.fn.strdisplaywidth(suffix)
            local targetWidth = width - sufWidth
            local curWidth = 0
            for _, chunk in ipairs(virtText) do
                local chunkText = chunk[1]
                local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                if targetWidth > curWidth + chunkWidth then
                    table.insert(newVirtText, chunk)
                else
                    chunkText = truncate(chunkText, targetWidth - curWidth)
                    table.insert(newVirtText, { chunkText, chunk[2] })
                    break
                end
                curWidth = curWidth + chunkWidth
            end
            table.insert(newVirtText, { suffix, "MoreMsg" })
            return newVirtText
        end,
    },
    keys = {
        { "zR", function() require("ufo").openAllFolds() end,  desc = "Open all folds" },
        { "zM", function() require("ufo").closeAllFolds() end, desc = "Close all folds" },
        { "zp", function() require("ufo").peekFoldedLinesUnderCursor() end, desc = "Peek fold" },
    },
}
