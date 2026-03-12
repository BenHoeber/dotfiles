return { -- Collection of various small independent plugins/modules
  'echasnovski/mini.nvim',
  config = function()
    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
    --  - ci'  - [C]hange [I]nside [']quote
    require('mini.ai').setup { n_lines = 500 }

    -- For automatic braket pairing
    require('mini.pairs').setup()
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup()
    -- Add this (the standard mapping) because mini.suround overwrites it
    vim.keymap.del('n', 's')

    -- `HJKL` for moving visual selection (overrides H, L, J in Visual mode)
    require('mini.move').setup {
      mappings = {
        left = 'H',
        right = 'L',
        down = 'J',
        up = 'K',
      },
    }
  end,
}
