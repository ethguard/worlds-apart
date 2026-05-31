vim.opt.number = true
vim.opt.relativenumber = true

vim.diagnostic.config({
  virtual_text = true, -- Error Lens (текст ошибки рядом с кодом)
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
