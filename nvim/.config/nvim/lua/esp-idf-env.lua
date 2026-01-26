-- Auto-load ESP-IDF environment when in ESP project
local M = {}

function M.setup_esp_env()
  -- Check if we're in an ESP-IDF project
  local function is_esp_project()
    local cwd = vim.fn.getcwd()
    -- Look for ESP-IDF project indicators
    local indicators = {
      "sdkconfig",
      "sdkconfig.defaults",
      "main/main.c",
      "main/main.cpp",
      "CMakeLists.txt"
    }
    
    for _, indicator in ipairs(indicators) do
      if vim.fn.filereadable(cwd .. "/" .. indicator) == 1 then
        return true
      end
    end
    return false
  end

  -- Set ESP-IDF environment variables
  local function set_esp_env()
    local esp_idf_path = vim.fn.expand("~/esp/v5.5-rc1/esp-idf")
    if vim.fn.isdirectory(esp_idf_path) == 1 then
      vim.env.IDF_PATH = esp_idf_path
      
      -- Set up Python environment properly
      local python_env = vim.fn.expand("~/.espressif/python_env/idf5.5_py3.13_env/bin")
      if vim.fn.isdirectory(python_env) == 1 then
        vim.env.PATH = python_env .. ":" .. (vim.env.PATH or "")
      end
      
      -- Add ESP-IDF tools to PATH
      local esp_tools = {
        esp_idf_path .. "/tools",
        vim.fn.expand("~/.espressif/tools/xtensa-esp-elf/esp-14.2.0_20241119/xtensa-esp-elf/bin"),
        vim.fn.expand("~/.espressif/tools/esp-clang/esp-19.1.2_20250312/esp-clang/bin"),
        vim.fn.expand("~/.espressif/tools/cmake/3.30.2/CMake.app/Contents/bin"),
      }
      
      for _, tool_path in ipairs(esp_tools) do
        if vim.fn.isdirectory(tool_path) == 1 then
          if not string.find(vim.env.PATH or "", tool_path, 1, true) then
            vim.env.PATH = tool_path .. ":" .. (vim.env.PATH or "")
          end
        end
      end
      
      -- Set other ESP-IDF environment variables
      vim.env.IDF_PYTHON_ENV_PATH = vim.fn.expand("~/.espressif/python_env/idf5.5_py3.13_env")
      vim.env.IDF_TOOLS_PATH = vim.fn.expand("~/.espressif")
      
      return true
    end
    return false
  end

  -- Auto-setup when opening ESP project
  if is_esp_project() then
    set_esp_env()
  end
end

return M
