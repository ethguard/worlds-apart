return {
  {
    'goolord/alpha-nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function ()
      local alpha = require('alpha')
      local dashboard = require('alpha.themes.dashboard')

      -- ASCII-арт
      dashboard.section.header.val = {
        [[                                      ]],
        [[████████╗███████╗██╗ ██████╗ ██╗   ██╗]],
        [[╚══██╔══╝██╔════╝██║██╔════╝ ██║   ██║]],
        [[   ██║   █████╗  ██║██║  ███╗██║   ██║]],
        [[   ██║   ██╔══╝  ██║██║   ██║██║   ██║]],
        [[   ██║   ███████╗██║╚██████╔╝╚██████╔╝]],
        [[   ╚═╝   ╚══════╝╚═╝ ╚═════╝  ╚═════╝ ]],
        [[                                      ]],
        [[                                      ]], 
        [[                                      ]], 
      }

      -- Кнопки
      dashboard.section.buttons.val = {
        dashboard.button("n", "  Новый файл", ":ene <BAR> startinsert <CR>"),
        dashboard.button("f", "󰈞  Поиск файлов", ":Telescope find_files <CR>"),
        dashboard.button("r", "󰄉  Недавние файлы", ":Telescope oldfiles <CR>"),
        dashboard.button("g", "󰊄  Поиск по тексту", ":Telescope live_grep <CR>"),
        dashboard.button("c", "  Конфиг Neovim", ":e ~/.config/nvim/init.lua <CR>"),
        dashboard.button("q", "󰅚  Выход", ":qa<CR>"),
      }

      dashboard.section.header.opts.position = "center"
      dashboard.section.buttons.opts.position = "center"
      dashboard.section.footer.opts.position = "center"

      dashboard.section.header.opts.hl = "AlphaHeader"
      dashboard.section.buttons.opts.hl = "Keyword"

      alpha.setup(dashboard.opts)
    end
  }
}
