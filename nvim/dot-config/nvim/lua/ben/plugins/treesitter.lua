--- @class TreesitterSpec
---
--- Filetypes to activate a tree sitter language for.
--- @field ft FileType[]
---
--- If true, activate treesitter indentation for this language. Otherwise use
--- vim default (based on regex). Indentation, if available, is defined in a
--- query file called `indents.scm`.
--- @field indent boolean?

--- Name of the tree sitter parser/language (as defined by `nvim-treesitter`).
--- @alias TreesitterLanguage string

--- File type (as defined by `nvim` itself, see `:set ft=<Ctrl+d>`)
--- @alias FileType string

--- Mapping from tree sitter language to custom specification for setup
---
--- @type table<TreesitterLanguage, TreesitterSpec>
local parser_table = {
  -- Programming languages
  bash = { ft = { 'sh', 'bash' } },
  jq = { ft = { 'jq' } },
  julia = { ft = { 'julia' }, indent = true },
  python = { ft = { 'python' }, indent = true },
  lua = { ft = { 'lua' }, indent = true },
  rust = { ft = { 'rust' }, indent = true },
  typst = { ft = { 'typst' }, indent = true },
  latex = { ft = { 'latex' }, indent = true },
  -- Svelte and web technologies
  svelte = { ft = { 'svelte' }, indent = true },
  javascript = { ft = { 'javascript', 'js' }, indent = true },
  typescript = { ft = { 'typescript', 'ts' }, indent = true },
  tsx = { ft = { 'typescriptreact' }, indent = true },
  jsx = { ft = { 'javascriptreact' }, indent = true },
  html = { ft = { 'html' }, indent = true },
  css = { ft = { 'css' }, indent = true },
  scss = { ft = { 'scss' }, indent = true },
  -- File formats
  csv = { ft = { 'csv' } },
  dockerfile = { ft = { 'dockerfile' } },
  editorconfig = { ft = { 'editorconfig' } },
  json = { ft = { 'json' }, indent = true },
  -- jsonc = { ft = { 'jsonc' }, indent = true },
  luadoc = { ft = { 'lua' } },
  make = { ft = { 'make' } },
  readline = { ft = { 'readline' }, indent = true },
  ssh_config = { ft = { 'sshconfig' }, indent = true },
  toml = { ft = { 'toml' }, indent = true },
  udev = { ft = { 'udevrules' } },
  yaml = { ft = { 'yaml' }, indent = true },
  diff = { ft = { 'diff' } },
  kdl = { ft = { 'kdl' }, indent = true },
  -- git, there is so much stuff for git...
  git_config = { ft = { 'gitconfig' } },
  git_rebase = { ft = { 'gitrebase' } },
  gitcommit = { ft = { 'gitcommit' } },
  gitignore = { ft = { 'gitignore' } },
  -- Markups
  markdown = { ft = { 'markdown' }, indent = true },
  markdown_inline = { ft = { 'markdown' } },
  printf = { ft = {} },
  regex = { ft = {} },
  -- Virtually everything injects this into comments
  comment = { ft = {} },
  -- Tree sitter specials
  query = { ft = { 'query' }, indent = true },
  scheme = { ft = { 'scheme' } },
}

--- Inverse lookup for `parser_table` from filetype to table key (language).
--- This exists only for performance reasons since it's required in the
--- filetype auto command.
--- @type table<FileType, TreesitterLanguage[]>
local filetype_table = {}
--- All the tree sitter languages we have configured (for installation)
local languages = {}
--- All the filetypes we have languages for (for auto command setup)
local filetypes = {}
for lang, obj in pairs(parser_table) do
  table.insert(languages, lang)
  vim.list_extend(filetypes, obj.ft)

  for _, ft in ipairs(obj.ft) do
    if filetype_table[ft] ~= nil then
      table.insert(filetype_table[ft], lang)
    else
      filetype_table[ft] = { lang }
    end
  end
end

--- Time constants (for sleep durations)
local MILLISECONDS_PER_SECOND = 1000
local SECONDS_PER_MINUTE = 60
local MINUTE_AS_MILLISECONDS = MILLISECONDS_PER_SECOND * SECONDS_PER_MINUTE

--- Maximum file size (in bytes) to apply tree sitter for. Files larger than
--- this are ignored.
local MAX_FILESIZE_BYTES = 1024 * 1024

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter').setup {
      install_dir = vim.fn.stdpath 'cache' .. '/treesitter',
    }

    local has_treesitter_cli = vim.fn.executable 'tree-sitter' == 1
    if has_treesitter_cli then
      require('nvim-treesitter')
          .install(languages, {
            force = false,
            generate = false,
            summary = false,
          })
          :wait(1 * MINUTE_AS_MILLISECONDS)
    else
      vim.schedule(function()
        vim.notify(
          'tree-sitter CLI not found; skipping parser installation. Install tree-sitter (npm i -g tree-sitter-cli or cargo install tree-sitter-cli) and reopen nvim.',
          vim.log.levels.WARN,
          { title = 'nvim-treesitter' }
        )
      end)
    end

    vim.api.nvim_create_autocmd('FileType', {
      desc = 'treesitter highlighting/folding/indentation',
      pattern = filetypes,
      callback = function(event)
        -- Skip treesitter setup for large files
        local ok, stats = pcall(vim.uv.fs_stat, event.file)
        if ok and stats and stats.size > MAX_FILESIZE_BYTES then
          return nil
        end

        local started = false
        local indent_ready = false
        for _, language in ipairs(filetype_table[event.match] or {}) do
          local ok = pcall(vim.treesitter.start, event.buf, language)
          if ok then
            started = true
            if parser_table[language].indent == true then
              indent_ready = true
            end
          else
            vim.schedule(function()
              vim.notify(
                ('Treesitter parser unavailable for %s; leaving buffer on regex highlighting.'):format(language),
                vim.log.levels.WARN,
                { title = 'nvim-treesitter' }
              )
            end)
          end
        end

        -- indentation, provided by nvim-treesitter (if supported and parser present)
        if started and indent_ready then
          vim.bo.indentexpr = [[v:lua.require("nvim-treesitter").indentexpr()]]
        end
      end,
    })
  end,
}
