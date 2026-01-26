-- cpp.lua
-- Comprehensive C/C++ development environment
--
-- Features:
--  • clangd LSP for completion, navigation, diagnostics
--  • codelldb DAP for debugging
--  • clang-format for code formatting
--  • clang-tidy for linting
--
-- Requirements:
--  • compile_commands.json for best clangd results
--    Generate with:
--      CMake: cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -B build
--      Make:  bear -- make
--
-- Keymaps: (inherited from global LSP config)
--  • gd - Go to definition
--  • gD - Go to declaration (useful for headers!)
--  • gr - Find references
--  • <leader>ca - Code actions
--  • <F5> - Start/continue debugging
--  • <leader>b - Toggle breakpoint
--  • <F1> - Step into
--  • <F2> - Step over
--  • <F3> - Step out
--  • <F7> - Toggle DAP UI

return {
  -- LSP Configuration
  {
    'neovim/nvim-lspconfig',
    ft = { 'c', 'cpp', 'h', 'hpp' },
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      require('lspconfig').clangd.setup {
        capabilities = capabilities,
        filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
        cmd = {
          'clangd',
          '--background-index',
          '--clang-tidy',
          '--header-insertion=iwyu',
          '--completion-style=detailed',
          '--function-arg-placeholders',
        },
        root_dir = function(fname)
          return require('lspconfig.util').root_pattern(
            'compile_commands.json',
            '.clangd',
            '.git',
            'CMakeLists.txt',
            'Makefile'
          )(fname)
        end,
        on_attach = function(client, bufnr)
          -- Add C-specific keymap for header/source switching
          vim.keymap.set('n', '<leader>ch', '<cmd>ClangdSwitchSourceHeader<cr>',
            { buffer = bufnr, desc = '[C] Switch Header/Source' })
        end,
      }
    end,
  },

  -- DAP Configuration (integrates with existing debug.lua)
  {
    'mfussenegger/nvim-dap',
    ft = { 'c', 'cpp' },
    config = function()
      local dap = require 'dap'

      -- Configure codelldb adapter
      dap.adapters.codelldb = {
        type = 'server',
        port = '${port}',
        executable = {
          command = vim.fn.stdpath('data') .. '/mason/bin/codelldb',
          args = { '--port', '${port}' },
        },
      }

      -- C debug configurations
      dap.configurations.c = {
        {
          name = 'Launch executable',
          type = 'codelldb',
          request = 'launch',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
        },
        {
          name = 'Launch current file (with args)',
          type = 'codelldb',
          request = 'launch',
          program = function()
            -- Compile current file
            local file = vim.fn.expand('%:p')
            local out = vim.fn.expand('%:p:r')
            vim.fn.system('gcc -g -o ' .. out .. ' ' .. file)
            return out
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = function()
            local args_string = vim.fn.input('Arguments: ')
            return vim.split(args_string, ' ')
          end,
        },
        {
          name = 'Attach to process',
          type = 'codelldb',
          request = 'attach',
          pid = require('dap.utils').pick_process,
          args = {},
        },
      }

      -- C++ uses same configurations as C
      dap.configurations.cpp = dap.configurations.c
    end,
  },
}
