return {
  {
    'neovim/nvim-lspconfig',
    ft = { 'typescript', 'typescriptreact' },
    config = function()
      require('lspconfig').tsserver.setup {
        on_attach = function(client, bufnr)
          -- Optional: keymaps or other LSP features
        end,
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
      }
    end,
  },
}
