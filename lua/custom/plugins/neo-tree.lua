return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("neo-tree").setup({
      filesystem = {
        follow_current_file = true,
        hijack_netrw_behavior = "disabled",
      },
      window = {
        open_in_tab = true, -- Open files in a new tab
      },
      source_selector = {
      winbar = true, -- Show source selector in the window bar
      statusline = false,
      show_scrolled_off_parent_node = true,
    },
    })

    -- VSCode-like sidebar: <leader>e toggles, <leader>o jumps focus between
    -- the tree and the last code window so switching focus is one keystroke.
    vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle File [E]xplorer" })
    vim.keymap.set("n", "<leader>o", function()
      -- If focused on neo-tree, jump back to previous window; else focus tree
      if vim.bo.filetype == "neo-tree" then
        vim.cmd("wincmd p")
      else
        vim.cmd("Neotree focus")
      end
    end, { desc = "T[o]ggle focus between explorer and code" })

    -- Optional: open Neo-tree automatically on startup
    -- vim.api.nvim_create_autocmd("VimEnter", {
    --   callback = function()
    --     require("neo-tree.command").execute({ action = "show" })
    --   end,
    -- })
  end
}
