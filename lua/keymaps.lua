-- keymaps.lua
-- VSCode-like keymaps. Leader is <Space>.
-- Search, file/folder ops, code nav, format, terminal, tabs, buffers.

local M = {}

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true, noremap = true })
end

function M.setup()
  -----------------------------------------------------------------------------
  -- Tabs (VSCode-style "open file in new tab")
  -----------------------------------------------------------------------------
  map('n', '<leader>tn', '<cmd>tabnew<CR>',           '[T]ab [N]ew')
  map('n', '<leader>tc', '<cmd>tabclose<CR>',         '[T]ab [C]lose')
  map('n', '<leader>to', '<cmd>tabonly<CR>',          '[T]ab close [O]thers')
  map('n', '<Tab>',      '<cmd>tabnext<CR>',          'Next tab')
  map('n', '<S-Tab>',    '<cmd>tabprevious<CR>',      'Previous tab')
  -- gt / gT still work as vim defaults

  -- Open the file under cursor in a new tab (works in Neo-tree with default 't')
  map('n', '<leader>tf', '<cmd>tabedit %<CR>',        '[T]ab from current [F]ile')

  -----------------------------------------------------------------------------
  -- Buffers (scratch / unsaved scratch buffer)
  -----------------------------------------------------------------------------
  -- A new, throwaway buffer that never asks to be saved
  map('n', '<leader>bn', function()
    vim.cmd('enew')
    vim.bo.buftype  = 'nofile'   -- not backed by a file -> no save prompt
    vim.bo.bufhidden = 'hide'
    vim.bo.swapfile = false
  end, '[B]uffer [N]ew (scratch, no save)')

  map('n', '<leader>bN', '<cmd>enew<CR>',             '[B]uffer [N]ew (normal)')
  map('n', '<leader>bd', '<cmd>bdelete!<CR>',         '[B]uffer [D]elete (force)')
  map('n', '<leader>bp', '<cmd>bprevious<CR>',        '[B]uffer [P]revious')
  map('n', '<leader>bx', '<cmd>bnext<CR>',            '[B]uffer ne[X]t')

  -----------------------------------------------------------------------------
  -- Files / Folders (create new files & folders from anywhere)
  -- In Neo-tree, the default keys 'a' (add), 'd' (delete), 'r' (rename),
  -- 'c' (copy), 'm' (move) all work already.
  -----------------------------------------------------------------------------
  -- Create a new file in the current working directory
  map('n', '<leader>nf', function()
    local name = vim.fn.input('New file: ', vim.fn.getcwd() .. '/', 'file')
    if name == '' then return end
    vim.cmd('edit ' .. vim.fn.fnameescape(name))
    vim.cmd('write')
  end, '[N]ew [F]ile')

  -- Create a new directory
  map('n', '<leader>nd', function()
    local name = vim.fn.input('New directory: ', vim.fn.getcwd() .. '/', 'dir')
    if name == '' then return end
    vim.fn.mkdir(name, 'p')
    print('Created ' .. name)
  end, '[N]ew [D]irectory')

  -----------------------------------------------------------------------------
  -- Code formatting by filetype (uses conform.nvim with LSP fallback)
  -----------------------------------------------------------------------------
  map('', '<leader>cf', function()
    require('conform').format { async = true, lsp_format = 'fallback' }
  end, '[C]ode [F]ormat')

  -----------------------------------------------------------------------------
  -- Terminal (builtin :terminal)
  -- VSCode opens a panel at the bottom; we mimic with a horizontal split.
  -----------------------------------------------------------------------------
  map('n', '<leader>tt', function()
    vim.cmd('botright 15split | terminal')
    vim.cmd('startinsert')
  end, '[T]erminal (horizontal split)')

  map('n', '<leader>tv', function()
    vim.cmd('vsplit | terminal')
    vim.cmd('startinsert')
  end, '[T]erminal [V]ertical split')

  -- Esc to leave terminal mode (also <Esc><Esc> from kickstart)
  map('t', '<C-\\>', [[<C-\><C-n>]], 'Exit terminal mode')

  -----------------------------------------------------------------------------
  -- Window/sidebar focus (Neo-tree)
  -- <leader>e opens/toggles, <leader>o focuses it (jump between code & tree)
  -----------------------------------------------------------------------------
  -- Configured inside neo-tree.lua to keep plugin-local concerns together.

  -----------------------------------------------------------------------------
  -- Quick save (VSCode-style Ctrl+S; works in normal & insert mode)
  -----------------------------------------------------------------------------
  map('n', '<C-s>', '<cmd>write<CR>',           'Save file')
  map('i', '<C-s>', '<Esc><cmd>write<CR>',      'Save file')

  -----------------------------------------------------------------------------
  -- Code navigation reminders (defined by LSP attach in init.lua):
  --   gd  -> Go to Definition
  --   gr  -> Find References
  --   gI  -> Go to Implementation
  --   gD  -> Go to Declaration
  --   <leader>D  -> Type Definition
  --   <leader>ds -> Document Symbols
  --   <leader>ws -> Workspace Symbols
  --   <leader>rn -> Rename
  --   <leader>ca -> Code Action
  --   K          -> Hover docs (vim default with LSP)
  -----------------------------------------------------------------------------
end

return M
