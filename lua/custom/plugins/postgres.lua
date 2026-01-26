return {
  {
    'neovim/nvim-lspconfig',
    ft = { 'sql', 'pgsql', 'plpgsql' },
    config = function()
      require('lspconfig').postgres_lsp.setup {
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
        filetypes = { 'sql', 'pgsql', 'plpgsql' },
        on_attach = function(client, bufnr)
          -- LSP keymaps are configured globally in init.lua
          -- Add any PostgreSQL-specific keymaps here if needed
        end,
      }
    end,
  },
}
