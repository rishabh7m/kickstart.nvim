-- groovy.lua
-- Groovy-specific Neovim configuration.
--
--  • Indentation: 4-space, auto-retab on save (global when `expandtab` is on)
--  • Adds Groovy parser to Treesitter *after* the plugin is loaded*
--  • Starts the Groovy Language Server
--
--  *Why defer Treesitter?*
--  When you invoke `require("groovy").setup()` from your `init.lua`, Lazy-managed
--  plugins like **nvim-treesitter** may not be loaded yet.  We therefore attempt
--  to patch Treesitter immediately *and* once Lazy reports it has finished
--  loading, preventing the classic “module not found” error you hit.

local M = {}

----------------------------------------------------------------
-- internal helper: make sure Treesitter knows about Groovy
----------------------------------------------------------------
local function ensure_treesitter_groovy()
  local ok, configs = pcall(require, "nvim-treesitter.configs")
  if not ok then
    return  -- Treesitter not loaded yet; try again later.
  end

  -- Build a safe opts table that merges with any existing config.
  local ts_opts = {
    ensure_installed = { "groovy" },
    indent          = { enable = true },
  }

  local current = configs.ensure_installed or {}
  if type(current) == "table" then
    local has = false
    for _, lang in ipairs(current) do
      if lang == "groovy" then has = true; break end
    end
    if not has then
      vim.list_extend(current, { "groovy" })
    end
    ts_opts.ensure_installed = current
  end

  configs.setup(ts_opts)
end

function M.setup()
  ----------------------------------------------------------------
  -- Indentation rules for Groovy/Jenkinsfile buffers
  ----------------------------------------------------------------
  -- vim.api.nvim_create_autocmd({ "FileType", "BufRead", "BufNewFile" }, {
  --   pattern = { "groovy", "Jenkinsfile" },
  --   callback = function()
  --     vim.bo.expandtab  = true  -- always use spaces
  --     vim.bo.shiftwidth = 4
  --     vim.bo.tabstop    = 4
  --   end,
  -- })

  ----------------------------------------------------------------
  -- Global retab: convert literal <Tab> chars to spaces on every save
  ----------------------------------------------------------------
  -- vim.api.nvim_create_autocmd("BufWritePre", {
  --   pattern = "*",
  --   callback = function()
  --     if vim.bo.expandtab then
  --       vim.cmd("silent! retab")
  --     end
  --   end,
  -- })

  ----------------------------------------------------------------
  -- Treesitter: patch now, and again once Lazy finishes loading plugins
  ----------------------------------------------------------------
  ensure_treesitter_groovy()
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyDone",
    callback = ensure_treesitter_groovy,
  })

  ----------------------------------------------------------------
  -- LSP: Groovy Language Server
  ----------------------------------------------------------------
  local lsp_ok, lspconfig = pcall(require, "lspconfig")
  if lsp_ok then
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    lspconfig.groovyls.setup({
      cmd          = { "groovy-language-server" },
      capabilities = capabilities,
      filetypes    = { "groovy", "Jenkinsfile" },
      on_attach    = function(_, bufnr)
        local map = function(lhs, rhs)
          vim.keymap.set("n", lhs, rhs, { buffer = bufnr })
        end
        map("gd", vim.lsp.buf.definition)
        map("K",  vim.lsp.buf.hover)
        map("<leader>rn", vim.lsp.buf.rename)
      end,
    })

    -- format-on-save for Groovy buffers
    -- vim.api.nvim_create_autocmd("BufWritePre", {
    --   pattern  = { "*.groovy", "Jenkinsfile" },
    --   callback = function() vim.lsp.buf.format({ async = false }) end,
    -- })
  end
end

return M
