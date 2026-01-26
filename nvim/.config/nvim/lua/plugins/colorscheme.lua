return {
  "rebelot/kanagawa.nvim",
  name="kanagawa-dragon",
  priority=1000,

  config = function()
    require'kanagawa'.setup{
      transparent=true,
      colors = {
        theme = { all = { ui = { bg_gutter = 'none' }  }}
      }
    }
    vim.cmd.colorscheme "kanagawa"
  end
}
