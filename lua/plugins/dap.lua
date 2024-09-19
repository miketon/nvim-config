local Config = {}

Config.plugin_spec = {
  "mfussenegger/nvim-dap",
  config = function()
    local dap = require("dap")
    -- Configure the lldb adapter
    dap.adapters.codelldb = {
      type = "server",
      port = "${port}",
      executable = {
        -- Use the codelldb provided by Mason
        command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
        args = { "--port", "${port}" },
      },
    }

    -- Setup configuration for Rust debugging
    dap.configurations.rust = {
      {
        name = "Launch",
        type = "codelldb",
        request = "launch",
        program = Config.get_rust_executable,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = {},
        -- Optional settings for console
        runInTerminal = false,
      },
    }
  end,
}

function Config.get_rust_executable()
  local cwd = vim.fn.getcwd()
  -- Get metadata using cargo
  -- - this is important when package name differs from directory name
  local metadata_json = vim.fn.system("cargo metadata --format-version 1 --no-deps")
  local metadata = vim.fn.json_decode(metadata_json)
  local target_name = nil
  if metadata and metadata.packages then
    for _, package in ipairs(metadata.packages) do
      if package.name and package.manifest_path:find(cwd) == 1 then
        target_name = package.name
        break
      end
    end
  end
  -- Fallback to using the folder name if package name not found
  if not target_name then
    target_name = vim.fn.fnamemodify(cwd, ":t")
  end

  local exe_path = cwd .. "/target/debug/" .. target_name
  if vim.fn.executable(exe_path) == 1 then
    return exe_path
  end
  return vim.fn.input("Path to executable: ", exe_path, "file")
end

return Config.plugin_spec
