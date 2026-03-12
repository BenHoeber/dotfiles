local has_cmp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
local capabilities = vim.lsp.protocol.make_client_capabilities()
if has_cmp then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

local function configure_server(name, config)
  config.capabilities = config.capabilities or capabilities
  vim.lsp.config[name] = config
  vim.lsp.enable(name)
end

configure_server('pylsp', {
  cmd = {
    'podman',
    'run',
    '--rm',
    '-i',
    '--entrypoint',
    'pylsp',
    '--network=host',
    '-v',
    vim.loop.cwd() .. ':' .. vim.loop.cwd() .. ':z',
    '-w',
    vim.loop.cwd(),
    '-e',
    'ENOS_*',
    'registry.sulzmann.energy/work/enos/enos-backend/python:0.15.0',
  },
  filetypes = { 'python' },
  root_markers = { '.git', 'pyproject.toml', 'requirements.txt', 'setup.cfg', 'setup.py' },
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = {
          maxLineLength = 100,
        },
      },
    },
  },
})

local cwd = vim.loop.cwd()
local volume = cwd .. ':' .. cwd .. ':z'
local jul = { 'julia' }
if vim.fn.filereadable './Project.toml' == 0 or vim.fn.filereadable './../Project.toml' == 0 then
  jul = {
    'podman',
    'run',
    '--rm',
    '-i',
    '--network=host',
    '-v',
    volume,
    '-w',
    cwd,
    '-e',
    'ENOS_*',
    'registry.sulzmann.energy/work/enos/enos-backend/julia:0.15.0',
  }
end

configure_server('julials', {
  cmd = vim.fn.extend(jul, {
    '--startup-file=no',
    '--history-file=no',
    '-e',
    [[
      import Pkg
      try
          # Maybe the current env has LSP installed?
          import LanguageServer
          println(stderr, "using LSP from environment")
      catch
          has_lsp = isdir(Pkg.envdir()) && "nvim-lspconfig" in readdir(Pkg.envdir())
          Pkg.activate("nvim-lspconfig"; shared=true)
          if !(has_lsp)
              println(stderr, "performing initial LSP installation")
              Pkg.add("LanguageServer")
              println(stderr, "done")
          end
          import LanguageServer
      end
      Pkg.activate()

      depot_path = get(ENV, "JULIA_DEPOT_PATH", "")
      project_path = let
          dirname(something(
              ## 1. Finds an explicitly set project (JULIA_PROJECT)
              Base.load_path_expand((
                  p = get(ENV, "JULIA_PROJECT", nothing);
                  p === nothing ? nothing : isempty(p) ? nothing : p
              )),
              ## 2. Look for a Project.toml file in the current working directory,
              ##    or parent directories, with $HOME as an upper boundary
              Base.current_project(),
              ## 3. First entry in the load path
              get(Base.load_path(), 1, nothing),
              ## 4. Fallback to default global environment,
              ##    this is more or less unreachable
              Base.load_path_expand("@v#.#"),
          ))
      end

      @info "Running language server" VERSION pwd() project_path depot_path
      server = LanguageServer.LanguageServerInstance(stdin, stdout, project_path, depot_path)
      server.runlinter = true
      run(server)
    ]]
  }),

  filetypes = { 'julia' },

  root_markers = { '.git', 'Project.toml' },

  settings = {
    julia = {
      symbolCacheDownload = true,
      format = { indent = 4, margin = 92 },
      completion = { snippets = false, },
      completionmode = "qualify",
      diagnostics = { enable = true }
    },
  },
})

configure_server('luals', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc' },
  settings = {
    Lua = {
      completion = {
        callSnippet = 'Replace',
      },
      runtime = {
        version = 'LuaJIT',
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          --       -- Load luvit types when the `vim.uv` word is found
          -- { path = '${3rd}/luv/library',    words = { 'vim%.uv' } },
          -- { path = '${3rd}/busted/library', words = { 'vim%.uv' } },
          -- Depending on the usage, you might want to add additional paths
          -- here.
          -- '${3rd}/luv/library'
          --
          -- '${3rd}/busted/library'
        },
      },
    },
  },
})

configure_server('tinymist', {
  cmd = { 'tinymist' },
  filetypes = { 'typst' },
  root_markers = { '.git' },
})

configure_server('svelte', {
  cmd = { 'svelteserver', '--stdio' },
  filetypes = { 'svelte' },
  root_markers = {
    'package.json',
    '.git',
    'svelte.config.js',
    'svelte.config.cjs',
    'svelte.config.mjs',
    'svelte.config.ts',
  },

  root_dir = function(startpath)
    return vim.fs.root(startpath, {
      'package.json',
      '.git',
      'svelte.config.js',
      'svelte.config.cjs',
      'svelte.config.mjs',
      'svelte.config.ts',
    })
  end,

  settings = {
    svelte = {
      plugin = {
        html = {
          completions = {
            enable = true,
            emmet = true -- Enable Emmet abbreviations
          },
          hover = { enable = true },
          tagComplete = { enable = true } -- Auto-close tags
        },
        css = {
          completions = { enable = true },
          hover = { enable = true },
          diagnostics = { enable = true }
        },
        typescript = {
          hover = { enable = true },
          diagnostics = { enable = true },
          completions = { enable = true },
          codeActions = { enable = true },
          rename = { enable = true },
          semanticTokens = { enable = true }
        },
        svelte = {
          compilerWarnings = {
            -- Common warnings you might want to ignore:
            -- ['a11y-click-events-have-key-events'] = 'ignore',
            -- ['a11y-no-static-element-interactions'] = 'ignore',
          },
          diagnostics = { enable = true },
          rename = { enable = true },
          format = { enable = true }
        }
      }
    }
  },
})

-- configure_server('tsserver', {
--   cmd = { 'typescript-language-server', '--stdio' },
--   filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'jsx', 'tsx' },
--   root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
--   root_dir = function(startpath)
--     return vim.fs.root(startpath, { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' })
--   end,
-- })

configure_server('rust_analyzer', {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', 'rust-project.json', '.git' },
  settings = {
    ['rust-analyzer'] = {
      cargo = { buildScripts = { enable = true } },
      check = { command = 'clippy' },
    },
  },
})

-- configure_server('bashls', {
--   cmd = { 'bash-language-server', 'start' },
--   filetypes = { 'sh', 'bash' },
--   root_markers = { '.git', '.shellcheckrc' },
-- })

-- configure_server('html', {
--   cmd = { 'vscode-html-language-server', '--stdio' },
--   filetypes = { 'html' },
--   root_markers = { 'package.json', '.git' },
-- })

-- configure_server('cssls', {
--   cmd = { 'vscode-css-language-server', '--stdio' },
--   filetypes = { 'css', 'scss', 'less' },
--   root_markers = { 'package.json', '.git' },
-- })

-- configure_server('jsonls', {
--   cmd = { 'vscode-json-language-server', '--stdio' },
--   filetypes = { 'json', 'jsonc' },
--   root_markers = { 'package.json', '.git' },
-- })

-- configure_server('yamlls', {
--   cmd = { 'yaml-language-server', '--stdio' },
--   filetypes = { 'yaml', 'yml' },
--   root_markers = { '.git' },
-- })

-- configure_server('dockerls', {
--   cmd = { 'docker-langserver', '--stdio' },
--   filetypes = { 'dockerfile' },
--   root_markers = { 'Dockerfile', '.git' },
-- })

configure_server('marksman', {
  cmd = { 'marksman', 'server' },
  filetypes = { 'markdown' },
  root_markers = { '.git' },
})
