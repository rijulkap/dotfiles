return {
  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'saghen/blink.cmp',
			'folke/snacks.nvim'
    },

    config = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()

      local servers = {
        clangd = {
          cmd = {
            '/home/rk-dev/.espressif/tools/esp-clang/16.0.1-fe4f10a809/esp-clang/bin/clangd',
            '--background-index',
            '--query-driver=**',
          },
        },
        tinymist = {
          filetypes = { 'typst' },
        },
        basedpyright = {
          settings = {
            basedpyright = {
              typeCheckingMode = 'standard',
            },
          },
        },
        ruff = {},
        jsonls = {
          -- lazy-load schemastore when needed
          on_new_config = function(new_config)
            new_config.settings.json.schemas = new_config.settings.json.schemas or {}
            vim.list_extend(new_config.settings.json.schemas, require('schemastore').json.schemas())
          end,
          settings = {
            json = {
              format = {
                enable = true,
              },
              validate = { enable = true },
            },
          },
        },
        rust_analyzer = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },
      }

      require('mason').setup()

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            server.capabilities = vim.tbl_deep_extend('force', server.capabilities, require('blink.cmp').get_lsp_capabilities(server.config))
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

					local Snacks = require('snacks')

          map('gd', function() Snacks.picker.lsp_definitions() end, '[G]oto [D]efinition')
          map('gr',function() Snacks.picker.lsp_references() end, '[G]oto [R]eferences')
          map('gI',function() Snacks.picker.lsp_implementations() end, '[G]oto [I]mplementation')
          map('<leader>lq', vim.diagnostic.setloclist, 'Open diagnostic [l]sp [q]uickfix list')
          map('<leader>lr', vim.lsp.buf.rename, '[l]sp [R]ename')
          map('<leader>lc', vim.lsp.buf.code_action, '[l]sp [C]ode Action')
          -- map('K', vim.lsp.buf.hover, 'Hover Documentation')
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client.name == 'ruff' then
            -- Disable hover in favor of Pyright
            client.server_capabilities.hoverProvider = false
          end

          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      local default_diagnostic_config = {
        virtual_text = false,
        underline = true,
        severity_sort = true,
        float = {
          focusable = false,
          style = 'minimal',
          border = 'rounded',
          source = 'always',
          header = '',
          prefix = '',
        },
      }

      vim.diagnostic.config(default_diagnostic_config)

      vim.fn.sign_define('DiagnosticSignError', { text = '', texthl = 'DiagnosticSignError' })
      vim.fn.sign_define('DiagnosticSignWarn', { text = '', texthl = 'DiagnosticSignWarn' })
      vim.fn.sign_define('DiagnosticSignInfo', { text = '', texthl = 'DiagnosticSignInfo' })
      vim.fn.sign_define('DiagnosticSignHint', { text = '', texthl = 'DiagnosticSignHint' })

      vim.lsp.inlay_hint.enable(true)
      vim.lsp.set_log_level 'off'
    end,
  },
}
