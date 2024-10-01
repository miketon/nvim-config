-- Configuration Table
local RustConfig = {}
local RustTools = {}
-- Dependency check if dot is installed
function RustTools.is_graphviz_installed()
  return vim.fn.executable("dot") == 1
end

-- setup() less plugin_spec
-- @note : Do not call the nvim-lspconfig.rust_analyzer setup or set up the
-- LSP client for rust-analyzer manually, as doing so may cause conflicts
RustConfig.plugin_spec = {
  "mrcjkb/rustaceanvim", -- plugin name
  version = "5.2.3",
  -- lazy = false, -- This plugin is already lazy
  ft = { "rust" }, -- filetype this plugin applies to
}

-- Set rustaceanvim configuration
RustConfig.rustaceanvim = {
  tools = {
    hover_actions = {
      auto_focus = true,
    },
    inlay_hints = {
      auto = true,
    },
  },
  -- Begins server configuration
  server = {
    -- RustLsp keymaps

    -- on_attach is called when LSP client attaches to a buffer
    -- used to setup buffer for LSP features such as :
    --  - 1 - local keymaps
    --  - 2 - commands
    --  - 3 - settings
    on_attach = function(_, bufnr)
      -- arg `buffer` is the buffer id (number) that the LSP has attached to
      RustTools.setup_keymaps(bufnr)

      -- Add a new keymap for viewing crate graph
      vim.keymap.set("n", "<leader>rvcgi", function()
        RustTools.interactive_view_crate_graph()
      end, { buffer = bufnr, desc = "[r]ust: [v]iew [c]rate [g]raph [i]nteractive" })
      -- @todo: Resolve why interactive_view_crate_graph yields empy svg argh
      vim.keymap.set("n", "<leader>rvcgd", function()
        RustTools.view_crate_graph()
      end, { buffer = bufnr, desc = "[r]ust: [v]iew [c]rate [g]raph [d]efault" })
    end,

    settings = {
      ["rust-analyzer"] = {
        checkOnSave = {
          command = "clippy",
        },

        inlayHints = {
          bindingModeHints = { enable = false },
          chainingHints = { enable = true },
          closingBraceHints = { enable = true, minLines = 25 },
          closureReturnTypeHints = { enable = "always" },
          lifetimeElisionHints = { enable = "skip_trivial" },
          maxLength = 25,
          parameterHints = { enable = true },
          reborrowHints = { enable = "mutable" },
          renderColons = true,
          typeHints = { enable = true },
        },

        cargo = {
          -- resolves "use of undeclared crate or module" when using
          -- underscores is because the feature is not enabled compiling
          -- - cargo.toml : bevy-inspector-egui vs
          -- - main.rs : use bevy_inspector_egui::prelude::*;
          --    - with #[cfg(feature = "dev")]
          -- TODO: implement this at the per project level
          -- this was actually causing rustaceanvim to FAIL in projects where
          -- Cargo.toml did NOT DEFINE "dev"
          -- features = { "dev" },
          -- TODO: update to detect wasm workspaces only
          target = "wasm32-unknown-unknown",
        },
      },
    },
  },
}

function RustTools.setup_keymaps(bufnr)
  -- Keymaps options
  local opts = { buffer = bufnr, noremap = true, silent = false }

  -- lsp.buf keymaps
  local map = vim.keymap
  local extend = vim.tbl_extend

  -- @note : using RustLsp 'codeAction' for floating window ui
  map.set("n", "<leader>ra", function()
    vim.cmd.RustLsp("codeAction")
  end, extend("force", opts, { desc = "[r]ust: Code [a]ction" }))
  map.set("n", "<leader>roc", function()
    vim.cmd.RustLsp("openCargo")
  end, extend("force", opts, { desc = "[r]ust: [o]pen [c]argo.toml" }))
  map.set("n", "<leader>rod", function()
    vim.cmd.RustLsp("openDocs")
  end, extend("force", opts, { desc = "[r]ust: [o]pen [d]ocs" }))
  map.set("n", "<leader>rr", function()
    vim.cmd.RustLsp("runnables")
  end, extend("force", opts, { desc = "[r]ust: [r]unnables" }))
  map.set("n", "<leader>rrd", function()
    vim.cmd.RustLsp("debuggables")
  end, extend("force", opts, { desc = "[r]ust: [r]un [d]ebuggables" }))

  -- Cargo command keymaps
  map.set("n", "<leader>rcrT", function()
    -- vim.system is ASYNC, vim.fn.system is NOT
    vim.system({ "cargo", "run", "--features", "dev" })
  end, extend("force", opts, { desc = "[r]ust : ![c]argo [r]un (dev [T]RUE)" }))

  map.set("n", "<leader>rcrF", function()
    vim.system({ "cargo", "run", "--no-default-features" })
  end, extend("force", opts, { desc = "[r]ust : ![c]argo [r]un (dev [F]ALSE)" }))
end

function RustTools.interactive_view_crate_graph()
  vim.ui.input({ prompt = "Enter max depth for crate graph (default 3): " }, function(input)
    local max_depth = tonumber(input) or 3
    RustTools.view_crate_graph(nil, nil, max_depth)
  end)
end

function RustTools.view_crate_graph(backend, output, max_depth)
  if not RustTools.is_graphviz_installed() then
    vim.notify("Graphviz (dot) is not installed : Please install it to use this feature", vim.log.levels.ERROR)
    return
  end

  -- Default values
  backend = backend or "svg"
  output = output or "crate_graph.svg"
  max_depth = max_depth

  -- Validate backend
  local valid_backends = { "svg", "png", "dot" }
  if not vim.tbl_contains(valid_backends, backend) then
    vim.notify("Invalid backend, Please use 'svg', 'png' or 'dot'", vim.log.levels.ERROR)
    return
  end

  -- Construct the command
  local cmd
  if max_depth then
    -- local cmd = string.format("RustLsp crateGraph %s %s hierarchical, depth=%d", backend, output, depth)
    cmd = string.format("RustLsp crateGraph %s %s, depth=%d", backend, output, max_depth)
    vim.notify(string.format("Crate Graph generating with max_depth=%d @[ %s %s]", max_depth, backend, output))
  else
    cmd = string.format("RustLsp crateGraph %s %s", backend, output)
    vim.notify(string.format("Crate Graph generating DEFAULT @[ %s %s]", backend, output))
  end

  -- Execute the command
  local success, result = pcall(function()
    vim.cmd(cmd)
  end)

  if success then
    vim.notify(string.format("Crate graph generated: %s", output), vim.log.levels.INFO)
    -- Open the generated file (SVG or PNG)
    if backend == "svg" or backend == "png" then
      local open_cmd
      if vim.fn.has("mac") == 1 then
        open_cmd = "open"
      elseif vim.fn.has("unix") == 1 then
        open_cmd = "xdg-open"
      elseif vim.fn.has("win32") == 1 then
        open_cmd = "start"
      end

      if open_cmd then
        vim.fn.system(string.format("%s %s", open_cmd, output))
      else
        vim.notify("Unable to automatically open file, try opening it manually", vim.log.levels.WARN)
      end
    end
  else
    vim.notify("Failed to generate crate graph: " .. result, vim.log.levels.ERROR)
  end
end

-- Apply configuration
vim.g["rustaceanvim"] = RustConfig.rustaceanvim

return RustConfig.plugin_spec
