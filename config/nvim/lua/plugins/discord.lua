return {
  {
    "andweeb/presence.nvim",
    config = function()
      require("presence").setup({
        auto_update = true,
        main_image = "neovim", 
        log_level = nil,
        editing_text = "Editing %s",
        workspace_text = "Working on %s",
      })
    end
  }
}
