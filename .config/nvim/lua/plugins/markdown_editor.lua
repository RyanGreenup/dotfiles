return {
  "ryangreenup/markdown_editor.nvim", -- Replace with actual plugin path
  config = function()
    require("markdown_editor").setup({
      -- Configure list indentation (2 for CommonMark, 4 for some variants)
      list_indent = 2, -- Default: 2 spaces
      
      -- Enable auto-indentation when pressing Enter in lists
      auto_indent_lists = true, -- Default: true
    })

    -- Create autocmd for markdown keybindings
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "rmd" },
      callback = function()
        local opts = { buffer = true, silent = true }
        
        -- Setup auto-indentation for lists
        require("markdown_editor.lists").setup_auto_indent()

        -- Heading Creation
        vim.keymap.set({"n", "i"}, "<C-CR>", function()
          require("markdown_editor.headings").insert_child_heading()
        end, vim.tbl_extend("force", opts, { desc = "Create child heading" }))

        vim.keymap.set({"n", "i"}, "<M-CR>", function()
          require("markdown_editor.headings").insert_sibling_heading()
        end, vim.tbl_extend("force", opts, { desc = "Create sibling heading" }))

        -- Heading Promotion/Demotion with Children
        vim.keymap.set("n", "<M-l>", function()
          require("markdown_editor.headings").demote_heading_with_children()
        end, vim.tbl_extend("force", opts, { desc = "Demote heading with children" }))

        vim.keymap.set("n", "<M-h>", function()
          require("markdown_editor.headings").promote_heading_with_children()
        end, vim.tbl_extend("force", opts, { desc = "Promote heading with children" }))

        vim.keymap.set({"n", "i"}, "<Right>", function()
          require("markdown_editor.headings").demote_heading_with_children()
        end, vim.tbl_extend("force", opts, { desc = "Demote heading with children" }))

        vim.keymap.set({"n", "i"}, "<Left>", function()
          require("markdown_editor.headings").promote_heading_with_children()
        end, vim.tbl_extend("force", opts, { desc = "Promote heading with children" }))

        -- Single Heading Promotion/Demotion
        vim.keymap.set("n", "<C-l>", function()
          require("markdown_editor.headings").demote_heading()
        end, vim.tbl_extend("force", opts, { desc = "Demote current heading only" }))

        vim.keymap.set("n", "<C-h>", function()
          require("markdown_editor.headings").promote_heading()
        end, vim.tbl_extend("force", opts, { desc = "Promote current heading only" }))

        -- Alt+Arrow keys for single item promotion/demotion
        vim.keymap.set({"n", "i"}, "<M-Left>", function()
          require("markdown_editor.headings").promote_heading()
        end, vim.tbl_extend("force", opts, { desc = "Promote current item only" }))

        vim.keymap.set({"n", "i"}, "<M-Right>", function()
          require("markdown_editor.headings").demote_heading()
        end, vim.tbl_extend("force", opts, { desc = "Demote current item only" }))



        -- Heading Reordering
        vim.keymap.set("n", "<M-Up>", function()
          require("markdown_editor.reorder").move_heading_up()
        end, vim.tbl_extend("force", opts, { desc = "Move heading up" }))

        vim.keymap.set("n", "<M-Down>", function()
          require("markdown_editor.reorder").move_heading_down()
        end, vim.tbl_extend("force", opts, { desc = "Move heading down" }))

        -- Link Management
        vim.keymap.set("n", "<C-c><C-l>", function()
          require("markdown_editor.links").smart_link()
        end, vim.tbl_extend("force", opts, { desc = "Create or edit markdown link" }))

        vim.keymap.set("v", "<C-c><C-l>", function()
          require("markdown_editor.links").smart_link(true)
        end, vim.tbl_extend("force", opts, { desc = "Create link from selection" }))

        -- Navigation
        vim.keymap.set("n", "<C-c><C-n>", function()
          require("markdown_editor.navigation").next_sibling_heading()
        end, vim.tbl_extend("force", opts, { desc = "Next sibling heading" }))

        vim.keymap.set("n", "<C-c><C-p>", function()
          require("markdown_editor.navigation").previous_sibling_heading()
        end, vim.tbl_extend("force", opts, { desc = "Previous sibling heading" }))

        vim.keymap.set("n", "<C-c><C-f>", function()
          require("markdown_editor.navigation").next_heading()
        end, vim.tbl_extend("force", opts, { desc = "Next heading (any level)" }))

        vim.keymap.set("n", "<C-c><C-b>", function()
          require("markdown_editor.navigation").previous_heading()
        end, vim.tbl_extend("force", opts, { desc = "Previous heading (any level)" }))

        vim.keymap.set("n", "<C-c><C-u>", function()
          require("markdown_editor.navigation").parent_heading()
        end, vim.tbl_extend("force", opts, { desc = "Parent heading" }))

        -- Folding
        vim.keymap.set("n", "<S-Tab>", function()
          require("markdown_editor.folding").cycle_fold()
        end, vim.tbl_extend("force", opts, { desc = "Cycle fold state" }))
      end,
    })
  end,
}

