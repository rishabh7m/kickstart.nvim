return {
  {
    'neovim/nvim-lspconfig',
    ft = { 'javascriptreact', 'typescriptreact' },
    config = function()
      -- Already handled in ts.lua, just here for ft coverage
    end,
  },
  {
    'windwp/nvim-ts-autotag', -- auto-close and rename JSX tags
    ft = { 'javascriptreact', 'typescriptreact', 'html' },
    config = function()
      require('nvim-ts-autotag').setup()
    end,
  },
  {
    'styled-components/vim-styled-components', -- Optional for styled-components
    ft = { 'javascriptreact', 'typescriptreact' },
  },
}
