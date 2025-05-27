-- keymaps.lua

local M = {}

function M.setup()
  -- Example: format current buffer on <leader>f
  vim.keymap.set("n", "<leader>f", function()
    vim.lsp.buf.format()
  end, { desc = "Format current buffer" })

  -- Add more keymaps here...
end

return M

