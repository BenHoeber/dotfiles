-- Define the function
local function git_status_with_window_handling()
  -- Get current window width
  local win_width = vim.api.nvim_win_get_width(0)

  -- Execute :Git (from fugitive)
  vim.cmd 'Git'

  -- Optional: slight delay to ensure :Git has opened the window before moving
  vim.defer_fn(function()
    -- If the width is greater than 140, move the Git window to the right
    if win_width > 140 then
      -- Move the window right (assuming :Git opens in a split)
      vim.cmd 'wincmd L'
    end
  end, 5) -- 5 ms delay to wait for the window to open properly
end

-- Set up key mapping for <leader>gs to call the function
vim.keymap.set('n', '<leader>gs', git_status_with_window_handling, { noremap = true, silent = true })

return {
  'tpope/vim-fugitive',
  event = 'VeryLazy', -- Load when these commands are used
  keys = {
    { '<leader>gs', git_status_with_window_handling, desc = 'Git status' },
    { '<leader>gc', '<cmd>Git commit<CR>', desc = 'Git commit' },
    { '<leader>gp', '<cmd>Git push<CR>', desc = 'Git push' },
    { '<leader>gd', '<cmd>Gvdiffsplit<CR>', desc = 'Git [d]iff vertical split' },

    -- 🔀 Conflict resolution
    { '<leader>ch', '<cmd>diffget //2<CR>', desc = 'Get Ours (//2 - left)' },
    { '<leader>cl', '<cmd>diffget //3<CR>', desc = 'Get Theirs (//3 - right)' },
    { '<leader>cp', '<cmd>diffput //1<CR>', desc = 'Put from current Buffer (to //1 - middle)' },

    -- ⬆️⬇️ Navigate between conflict markers
    { ']x', '/^<<<<<<<\\|^=======$\\|^>>>>>>>$/<CR>', desc = 'Next conflict marker' },
    { '[x', '?^<<<<<<<\\|^=======$\\|^>>>>>>>$/<CR>', desc = 'Previous conflict marker' },

    -- 🚧 Rebase/Merge controls
    { '<leader>cm', '<cmd>Git merge --continue<CR>', desc = 'Merge continue' },
    { '<leader>mA', '<cmd>Git merge --abort<CR>', desc = 'Merge abort' },
    { '<leader>cr', '<cmd>Git rebase --continue<CR>', desc = 'Rebase continue' },
    { '<leader>rA', '<cmd>Git rebase --abort<CR>', desc = 'Rebase abort' },
    { '<leader>gb', '<cmd>Git blame<CR>', desc = 'Git blame' },
  },
  config = function()
    -- Optionally add autocommands or mappings specific to fugitive buffers here
    -- Example: map 'q' to quit fugitive windows easily
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'fugitive',
      callback = function()
        vim.keymap.set('n', 'q', '<cmd>q<CR>', { buffer = true, desc = 'Quit Fugitive' })
      end,
    })
    -- Map 'q' to close any diff window
    vim.api.nvim_create_autocmd('WinEnter', {
      callback = function()
        if vim.wo.diff then
          vim.keymap.set('n', 'q', '<cmd>:q<CR>', { buffer = true, desc = 'Close diff window' })
        end
      end,
    })
  end,
}
