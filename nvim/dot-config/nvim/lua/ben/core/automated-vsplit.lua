-- Function to move specific filetypes to vertical split if the current window is wider than threshold
-- Creates independent autocmds for each filetype with different width thresholds
local function openVerticallyIfWide(filetype, width_threshold)
  -- Create a unique augroup name for this filetype to prevent duplicates
  local augroup_name = 'AutoVerticalSplit_' .. filetype

  -- Create or clear the augroup
  vim.api.nvim_create_augroup(augroup_name, { clear = true })

  -- Shared function to handle window checking and splitting
  local function check_and_split()
    -- Get current window BEFORE deferring
    local win_id = vim.api.nvim_get_current_win()

    -- Get window width BEFORE deferring
    local win_width = vim.api.nvim_win_get_width(0)

    -- Store buffer information to verify it's still the same after deferring
    local buf_id = vim.api.nvim_win_get_buf(win_id)

    -- Check if window is wider than threshold immediately
    if win_width > width_threshold then
      -- Defer execution to avoid race conditions during window setup
      vim.defer_fn(function()
        -- Verify we're still in the same window/buffer context
        local current_win = vim.api.nvim_get_current_win()
        local current_buf = vim.api.nvim_win_get_buf(current_win)

        -- Only proceed if we're still in the expected context
        if current_win == win_id and current_buf == buf_id then
          -- Check filetype once more before moving
          local current_ft = vim.bo[current_buf].filetype
          if current_ft == filetype then
            -- Move current window to a vertical split on the far right
            vim.cmd 'wincmd L'
          end
        end
      end, 5) -- 5 delay gives Neovim time to finish window setup
    end
  end

  -- Create autocmds for the specific filetype with multiple triggers
  for _, event in ipairs { 'FileType', 'BufWinEnter', 'BufAdd', 'WinEnter' } do
    vim.api.nvim_create_autocmd(event, {
      group = augroup_name,
      pattern = event == 'FileType' and filetype or '*',
      callback = function()
        -- For non-FileType events, check if the filetype matches
        if event ~= 'FileType' then
          local buf_ft = vim.bo.filetype
          if buf_ft ~= filetype then
            return
          end
        end

        check_and_split()
      end,
    })
  end
end

openVerticallyIfWide('help', 140)
openVerticallyIfWide('qf', 140)
openVerticallyIfWide('git', 140)
-- openVerticallyIfWide('fugitive', 140)
-- Not for fugitive because that opens things weirdly.
-- This is done via the <leader>gs keybinding and a special funciton
