return {
  "anurag3301/nvim-platformio.lua",
  dependencies = {
    { "akinsho/toggleterm.nvim" },
    { "nvim-telescope/telescope.nvim" },
    { "nvim-telescope/telescope-ui-select.nvim" },
    { "nvim-lua/plenary.nvim" },
    { "folke/which-key.nvim" },
  },
  cmd = {
    "Pioinit",
    "Piorun",
    "Piocmdh",
    "Piocmdf",
    "Piolib",
    "Piomon",
    "Piodebug",
    "Piodb",
  },
  config = function()
    local pok, platformio = pcall(require, "platformio")
    if pok then
      platformio.setup({
        lsp = "clangd", -- folosește clangd pentru LSP (generează și compile_commands.json)
        -- menu_key = "<leader>\\\\", -- decomentează pentru a activa meniul PlatformIO
      })
    end
  end,
}
