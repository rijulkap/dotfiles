return {
  {
    'saghen/blink.cmp',
    lazy = false, -- lazy loading handled internally
    -- optional: provides snippets for the snippet source
    dependencies = 'rafamadriz/friendly-snippets',

    -- use a release tag to download pre-built binaries
    version = 'v0.*',
    -- OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- On musl libc based systems you need to add this flag
    -- build = 'RUSTFLAGS="-C target-feature=-crt-static" cargo build --release',
    opts = {
      -- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- adjusts spacing to ensure icons are aligned
      completion = {
        menu = {
          winblend = vim.o.pumblend,
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
        list = {
          selection = { preselect = false, auto_insert = true },
        },
      },
      keymap = {
        preset = 'enter',
        ['<c-K>'] = { 'show', 'show_documentation', 'hide_documentation' },
        -- ['<esc>'] = { 'cancel', 'fallback' },
      },
      appearance = {
        nerd_font_variant = 'normal',
        kind_icons = {
          Array = ' ',
          Boolean = '󰨙 ',
          Class = ' ',
          Codeium = '󰘦 ',
          Color = ' ',
          Control = ' ',
          Collapsed = ' ',
          Constant = '󰏿 ',
          Constructor = ' ',
          Copilot = ' ',
          Enum = ' ',
          EnumMember = ' ',
          Event = ' ',
          Field = ' ',
          File = ' ',
          Folder = ' ',
          Function = '󰊕 ',
          Interface = ' ',
          Key = ' ',
          Keyword = ' ',
          Method = '󰊕 ',
          Module = ' ',
          Namespace = '󰦮 ',
          Null = ' ',
          Number = '󰎠 ',
          Object = ' ',
          Operator = ' ',
          Package = ' ',
          Property = ' ',
          Reference = ' ',
          Snippet = ' ',
          String = ' ',
          Struct = '󰆼 ',
          TabNine = '󰏚 ',
          Text = ' ',
          TypeParameter = ' ',
          Unit = ' ',
          Value = ' ',
          Variable = '󰀫 ',
        },
      },
			cmdline = {enabled = false},

      sources = {
        -- Remove 'buffer' if you don't want text completions, by default it's only enabled when LSP returns no items
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      -- experimental auto-brackets support
      -- accept = { auto_brackets = { enabled = true } }

      -- experimental signature help support
      -- trigger = { signature_help = { enabled = true } }
    },
  },
}
