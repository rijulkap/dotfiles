return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = 'VeryLazy',
    init = function()
      vim.g.lualine_laststatus = vim.o.laststatus
      if vim.fn.argc(-1) > 0 then
        -- set an empty statusline till lualine loads
        vim.o.statusline = ' '
      else
        -- hide the statusline on the starter page
        vim.o.laststatus = 0
      end
    end,
    opts = {

      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = { 'snacks_dashboard' },
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch' },
        lualine_c = {
          {
            function()
              local cwd = vim.fn.getcwd()
              local sep = package.config:sub(1, 1)
              local parts = vim.split(cwd, sep, { trimempty = true }) -- Split path by "/"

              -- Get last two parts or just return full path if <=2 parts
              if #parts > 2 then
                return '…/' .. parts[#parts - 1] .. '/' .. parts[#parts]
              else
                return cwd
              end
            end,
            icon = { ' ', color = 'Directory' },
            separator = '->',
            padding = { left = 1, right = 0 },
          },
          {
            'filename',
            padding = { left = 0, right = 1 },
          },
          {
            'diagnostics',
            symbols = {
              error = ' ',
              warn = ' ',
              info = ' ',
              hint = ' ',
            },
          },
        },
        lualine_x = {
          {
            function()
              return '  ' .. require('dap').status()
            end,
            cond = function()
              return package.loaded['dap'] and require('dap').status() ~= ''
            end,
          },
          {
            'diff',
            symbols = {
              added = ' ',
              modified = ' ',
              removed = ' ',
            },
            source = function()
              local gitsigns = vim.b.gitsigns_status_dict
              if gitsigns then
                return {
                  added = gitsigns.added,
                  modified = gitsigns.changed,
                  removed = gitsigns.removed,
                }
              end
            end,
          },
        },
        lualine_y = {
          { 'progress', separator = ' ', padding = { left = 1, right = 1 } },
        },
        lualine_z = { 'location' },
      },
    },
    config = function(_, opts)
      local virtual_env = function()
        -- only show virtual env for Python
        if vim.bo.filetype ~= 'python' then
          return ''
        end

        local conda_env = os.getenv 'CONDA_DEFAULT_ENV'
        local venv_path = os.getenv 'VIRTUAL_ENV'

        if venv_path == nil then
          if conda_env == nil then
            return ''
          else
            return string.format('%s (conda)', conda_env)
          end
        else
          local venv_name = vim.fn.fnamemodify(venv_path, ':t')
          return string.format('%s (venv)', venv_name)
        end
      end

      -- local lsp_name = function()
      --   if next(vim.g.lsp_names) ~= nil then
      --     local lsp = vim.g.lsp_names[vim.api.nvim_get_current_buf()]
      --     if lsp then
      --       return lsp
      --     end
      --   end
      --   return ''
      -- end

      local trouble = require 'trouble'
      local symbols = trouble.statusline {
        mode = 'lsp_document_symbols',
        groups = {},
        title = false,
        filter = { range = true },
        format = '{kind_icon}{symbol.name:Normal}',
        -- The following line is needed to fix the background color
        -- Set it to the lualine section you want to use
        hl_group = 'lualine_c_normal',
      }

      table.insert(opts.sections.lualine_c, {
        virtual_env,
      })

      table.insert(opts.sections.lualine_c, {
        symbols.get,
        cond = symbols.has,
      })

      table.insert(opts.sections.lualine_x, { 'filetype', icon_only = true, padding = { left = 1, right = 1 } })

      table.insert(opts.sections.lualine_x, {
        lsp_name,
      })

      require('lualine').setup(opts)
    end,
  },
}
