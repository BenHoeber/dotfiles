return {
  'nvim-treesitter/nvim-treesitter-context',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('treesitter-context').setup {
      enable = true, -- Enable this plugin
      max_lines = 4, -- How many lines the context window can span
      trim_scope = 'inner', -- Which context lines to show when above max_lines
      mode = 'cursor', -- Show context at cursor (can be "topline" too)
    }
  end,
}
