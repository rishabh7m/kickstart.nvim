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

    -- Key mapping to toggle Neo-tree
    vim.keymap.set("n", "<leader>p", ":Neotree toggle<CR>", { desc = "Toggle File Explorer" })
    vim.keymap.set("n", "<leader>pf", ":Neotree focus<CR>", { desc = "Focus Neo-tree" })

    -- Optional: open Neo-tree automatically on startup
    -- vim.api.nvim_create_autocmd("VimEnter", {
    --   callback = function()
    --     require("neo-tree.command").execute({ action = "show" })
    --   end,
    -- })
  end
}
