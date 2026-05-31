require('config')
require('keymappings')

-- Автоматическая установка менеджера плагинов (Lazy.nvim)

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- последняя стабильная версия
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)


--Мои настройки 

require('lazy').setup("plugins")	

-- Тема
vim.cmd("colorscheme carbonfox")
