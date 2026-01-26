return {
  {
    'mfussenegger/nvim-jdtls',
    ft = { 'java' },
    config = function()
      local jdtls = require('jdtls')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      
      -- Find root of project
      local root_markers = { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }
      local root_dir = require('jdtls.setup').find_root(root_markers)
      if not root_dir then
        return
      end

      local extendedClientCapabilities = jdtls.extendedClientCapabilities
      extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

      local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
      
      local workspace_dir = vim.fn.stdpath('data') .. '/site/java/workspace-root/' .. project_name
      os.execute('mkdir -p ' .. workspace_dir)

      -- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
      local config = {
        -- The command that starts the language server
        -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
        cmd = {
          'java',
          '-Declipse.application=org.eclipse.jdt.ls.core.id1',
          '-Dosgi.bundles.defaultStartLevel=4',
          '-Declipse.product=org.eclipse.jdt.ls.core.product',
          '-Dlog.protocol=true',
          '-Dlog.level=ALL',
          '-Xmx1g',
          '--add-modules=ALL-SYSTEM',
          '--add-opens', 'java.base/java.util=ALL-UNNAMED',
          '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
          '-jar',
          vim.fn.glob('/usr/local/share/java/jdtls/plugins/org.eclipse.equinox.launcher_*.jar'),
          '-configuration',
          '/usr/local/share/java/jdtls/config_mac',
          '-data',
          workspace_dir,
        },

        -- Here you can configure eclipse.jdt.ls specific settings
        -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
        -- for a list of options
        settings = {
          java = {
            eclipse = {
              downloadSources = true,
            },
            configuration = {
              updateBuildConfiguration = 'interactive',
              runtimes = {
                {
                  name = 'JavaSE-11',
                  path = '/usr/local/opt/openjdk@11/',
                },
                {
                  name = 'JavaSE-17',
                  path = '/usr/local/opt/openjdk@17/',
                },
                {
                  name = 'JavaSE-21',
                  path = '/usr/local/opt/openjdk/',
                },
              }
            },
            maven = {
              downloadSources = true,
            },
            implementationsCodeLens = {
              enabled = true,
            },
            referencesCodeLens = {
              enabled = true,
            },
            references = {
              includeDecompiledSources = true,
            },
            inlayHints = {
              parameterNames = {
                enabled = 'all',
              },
            },
            format = {
              enabled = true,
            },
            saveActions = {
              organizeImports = true,
            },
          },
          signatureHelp = { enabled = true },
          completion = {
            favoriteStaticMembers = {
              'org.hamcrest.MatcherAssert.assertThat',
              'org.hamcrest.Matchers.*',
              'org.hamcrest.CoreMatchers.*',
              'org.junit.jupiter.api.Assertions.*',
              'java.util.Objects.requireNonNull',
              'java.util.Objects.requireNonNullElse',
              'org.mockito.Mockito.*',
            },
          },
          contentProvider = { preferred = 'fernflower' },
          extendedClientCapabilities = extendedClientCapabilities,
          sources = {
            organizeImports = {
              starThreshold = 9999,
              staticStarThreshold = 9999,
            },
          },
          codeGeneration = {
            toString = {
              template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
            },
            useBlocks = true,
          },
        },

        -- Language server `initializationOptions`
        -- You need to extend the `bundles` with paths to jar files
        -- if you want to use additional eclipse.jdt.ls plugins.
        --
        -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
        --
        -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
        init_options = {
          bundles = {}
        },
        capabilities = capabilities,
        root_dir = root_dir,
        flags = {
          allow_incremental_sync = true,
        },
        on_attach = function(_, bufnr)
          local map = function(lhs, rhs, desc)
            vim.keymap.set('n', lhs, rhs, { buffer = bufnr, desc = desc })
          end
          
          -- LSP keymaps
          map('gd', vim.lsp.buf.definition, 'Go to definition')
          map('gD', vim.lsp.buf.declaration, 'Go to declaration')
          map('gr', vim.lsp.buf.references, 'Show references')
          map('gi', vim.lsp.buf.implementation, 'Go to implementation')
          map('K', vim.lsp.buf.hover, 'Show hover documentation')
          map('<C-k>', vim.lsp.buf.signature_help, 'Show signature help')
          map('<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
          map('<leader>ca', vim.lsp.buf.code_action, 'Code actions')
          map('<leader>D', vim.lsp.buf.type_definition, 'Type definition')
          map('<leader>f', function() vim.lsp.buf.format({ async = true }) end, 'Format code')
          
          -- Java-specific actions
          map('<leader>jo', jdtls.organize_imports, 'Organize imports')
          map('<leader>jv', jdtls.extract_variable, 'Extract variable')
          map('<leader>jc', jdtls.extract_constant, 'Extract constant')
          map('<leader>jm', jdtls.extract_method, 'Extract method')
          map('<leader>jtc', jdtls.test_class, 'Test class')
          map('<leader>jtm', jdtls.test_nearest_method, 'Test method')
          
          -- which-key mappings for Java-specific actions
          local wk_ok, wk = pcall(require, 'which-key')
          if wk_ok then
            wk.register({
              ['<leader>j'] = {
                name = '+java',
                o = 'Organize imports',
                v = 'Extract variable',
                c = 'Extract constant', 
                m = 'Extract method',
                t = {
                  name = '+test',
                  c = 'Test class',
                  m = 'Test method',
                },
              },
            }, { buffer = bufnr })
          end
        end,
      }
      
      -- This starts a new client & server,
      -- or attaches to an existing client & server depending on the `root_dir`.
      require('jdtls').start_or_attach(config)
      
      -- Auto-format on save for Java files
      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = '*.java',
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
    end,
  },
}