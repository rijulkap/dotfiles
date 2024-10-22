return {
  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      local open_with_trouble = require('trouble.sources.telescope').open
      -- local add_to_trouble = require('trouble.sources.telescope').add
      --
      require('telescope').setup {
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
        defaults = {
          prompt_prefix = ' ',
          selection_caret = ' ',
          path_display = { 'smart' },
          get_selection_window = function()
            local wins = vim.api.nvim_list_wins()
            table.insert(wins, 1, vim.api.nvim_get_current_win())
            for _, win in ipairs(wins) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].buftype == '' then
                return win
              end
            end
            return 0
          end,
          mappings = {
            n = {
              ['<c-c>'] = require('telescope.actions').delete_buffer,
              ['<c-t>'] = open_with_trouble,
              ['<tab>'] = require('telescope.actions').toggle_selection,
              ['<c-tab>'] = require('telescope.actions').toggle_selection + require('telescope.actions').move_selection_next,
            }, -- n
            i = {
              ['<C-h>'] = 'which_key',
              ['<c-c>'] = require('telescope.actions').delete_buffer,
              ['<c-t>'] = open_with_trouble,
              ['<tab>'] = require('telescope.actions').toggle_selection,
              ['<c-tab>'] = require('telescope.actions').toggle_selection + require('telescope.actions').move_selection_next,
            }, -- i
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', function()
        builtin.buffers { sort_mru = true, ignore_current_buffer = true }
      end, { desc = 'Find existing buffers' })

      vim.keymap.set('n', '<leader>s/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = 'Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      vim.keymap.set('n', '<leader>so', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })

      vim.keymap.set('n', '<leader>sv', '<cmd>Telescope vim_options<cr>', { desc = '[S]earch [V]im Options' })
      vim.keymap.set('n', '<leader>s:', '<cmd>Telescope command_history<cr>', { desc = '[S]earch [C]ommand History' })
      vim.keymap.set('n', '<leader>gc', '<cmd>Telescope git_commits<CR>', { desc = 'Search [G]it [C]ommits' })
      vim.keymap.set('n', '<leader>gs', '<cmd>Telescope git_status<CR>', { desc = 'Search [G]it [S]tatus' })
    end,
  },
}
