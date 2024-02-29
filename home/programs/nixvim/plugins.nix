{
  # TODO: Signs!
  programs.nixvim.plugins = {
    comment-nvim.enable = true;
    undotree.enable = true;
    telescope.enable = true;
    trouble.enable = true;
    which-key.enable = true;
    notify.enable = true;
    nvim-colorizer.enable = true;
    oil.enable = true;
    lastplace.enable = true;
    # yuck.enable = true;
    crates-nvim.enable = true;
    rust-tools.enable = true;
    lspkind.enable = true;
    cmp-nvim-lsp-signature-help.enable = true;
    treesitter.enable = true;
    cmp_luasnip.enable = true;
    luasnip.enable = true;
    gitsigns.enable = true;
    lualine.enable = true;
    lsp = {
      enable = true;
      servers = {
        # rust-analyzer.enable = true;
        lua-ls.enable = true;
        pylsp.enable = true;
      };
    };
    nvim-cmp = {
      enable = true;
      sources = [
        {name = "nvim_lsp";}
        {name = "path";}
        {name = "buffer";}
        {name = "luasnip";}
        {name = "nvim_lsp_signature_help";}
      ];
      mapping = {
        "<Up>" = "cmp.mapping.select_prev_item()";
        "<Down>" = "cmp.mapping.select_next_item()";
        "<C-k>" = "cmp.mapping.select_prev_item()";
        "<C-j>" = "cmp.mapping.select_next_item()";
        "<C-e>" = "cmp.mapping.abort()";
        "<C-CR>" = "cmp.mapping.confirm({ select = true })";
        "<CR>" = "cmp.mapping.confirm({ select = false })";
      };
    };
  };
}
