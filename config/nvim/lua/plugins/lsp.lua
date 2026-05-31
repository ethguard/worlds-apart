return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { 
          "pyright", "gopls", "yamlls", "dockerls", "bashls", "ansiblels" 
        },
      })

      require("lspconfig")

      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local servers = { "pyright", "gopls", "yamlls", "dockerls", "bashls", "ansiblels" }

      for _, lsp in ipairs(servers) do
        vim.lsp.config[lsp] = vim.tbl_deep_extend("force", vim.lsp.config[lsp] or {}, {
          capabilities = capabilities,
        })
        vim.lsp.enable(lsp)
      end
    end,
  }
}
