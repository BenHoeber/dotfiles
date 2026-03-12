return { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup {
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local hunk_search_active = false -- Buffer-local-like flag

          local function map(mode, keys, func, desc)
            vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = desc })
          end

          -- Function to start hunk search and map n/N
          local function start_hunk_search(direction)
            hunk_search_active = true

            -- Map 'n' and 'N' for hunk navigation
            vim.keymap.set('n', 'h', function()
              gs.next_hunk()
              vim.cmd 'normal! zz'
            end, { buffer = bufnr, desc = 'Next hunk (repeat)' })
            vim.keymap.set('n', 'H', function()
              gs.prev_hunk()
              vim.cmd 'normal! zz'
            end, { buffer = bufnr, desc = 'Previous hunk (repeat)' })

            -- Jump to first hunk
            if direction == 'next' then
              gs.next_hunk()
            else
              gs.prev_hunk()
            end
          end

          -- Function to exit hunk search and unmap n/N
          local function exit_hunk_search()
            if hunk_search_active then
              hunk_search_active = false
              vim.keymap.del('n', 'h', { buffer = bufnr })
              vim.keymap.del('n', 'H', { buffer = bufnr })
            end
          end

          -- Remap 'Esc' to exit hunk search or clear search highlight
          map('n', '<Esc>', function()
            if hunk_search_active then
              exit_hunk_search()
            else
              vim.cmd 'noh' -- Clear search highlights
            end
          end, 'Exit hunk search or clear search')

          -- Initial mappings for gh and gH to start hunk search mode
          map('n', 'gh', function()
            start_hunk_search 'next'
          end, 'Next hunk (search mode)')
          map('n', 'gH', function()
            start_hunk_search 'prev'
          end, 'Prev hunk (search mode)')

          -- (Optional) Add your normal gitsigns mappings here
          map('n', '<leader>hs', gs.stage_hunk, '[h] [s] Stage Hunk')
          map('n', '<leader>hu', gs.undo_stage_hunk, '[h] [u] Undo Stage Hunk')
          map('n', '<leader>hr', gs.reset_hunk, '[h] [r] Reset Hunk')
          map('n', '<leader>hp', gs.preview_hunk, '[h] [p] Preview Hunk')
          map('n', '<leader>hS', gs.stage_buffer, '[h] [S] Stage Buffer')
          map('v', '<leader>hs', function()
            gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end, '[h] [s] Stage Selection')
          map('v', '<leader>hr', function()
            gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end, '[h] [r] Reset Selection')
        end,
      }
    end,
  }
