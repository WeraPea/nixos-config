{
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
    # lsp_kind.enable = true;
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
      };
    };
    nvim-cmp = {
      enable = true;
      sources = [
        {name = "nvim_lsp";}
        {name = "path";}
        {name = "buffer";}
        {name = "luasnip";}
      ];
      mapping = {
        "<C-k>" = "cmp.mapping.select_prev_item()";
        "<C-j>" = "cmp.mapping.select_next_item()";
        # ["<C-Space>"] = cmp.mapping.complete(),
        "<C-e>" = "cmp.mapping.abort()";
        "<CR>" = "cmp.mapping.confirm({ select = true })";
        "<Tab>" = {
          action = ''
            function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                else
                    fallback()
                end
            end
          '';
          # elseif luasnip.expandable() then
          #     luasnip.expand()
          # elseif luasnip.expand_or_jumpable() then
          #     luasnip.expand_or_jump()
          # elseif check_backspace() then
          #     fallback()
          modes = ["i" "s"];
        };
        "<S-Tab>" = {
          action = ''
            function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                else
                    fallback()
                end
            end
          '';
          # elseif check_backspace() then
          #     fallback()
          # elseif luasnip.expandable() then
          #     luasnip.expand()
          # elseif luasnip.expand_or_jumpable() then
          #     luasnip.expand_or_jump()
          modes = ["i" "s"];
        };
      };
    };
  };
}
