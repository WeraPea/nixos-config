{...}: {
  programs.nixvim = {
    plugins = {
      # lightline.enable = true;
      # comment.enable = true;
      gitsigns.enable = true;
      lualine.enable = true;
      lsp.enable = {
        enable = true;
        servers = {
          rust-analyzer.enable = true;
          lua-ls.enable = true;
        };
      };
      nvim-cmp = {
        enable = true;
        autoEnableSources = true;
        sources = [
          {name = "nvim_lsp";}
          {name = "path";}
          {name = "buffer";}
        ];
        mapping = {
          "<C-k>" = "cmp.mapping.select_prev_item()";
          "<C-j>" = "cmp.mapping.select_next_item()";
          # ["<C-Space>"] = cmp.mapping.complete(),
          "<C-e>" = "cmp.mapping.abort()";
          "<CR>" = "cmp.mapping.confirm({ select = false })";
          "<C-CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = {
            action = ''
              function(fallback)
                  if cmp.visible() then
                      cmp.select_next_item()
                  elseif luasnip.expandable() then
                      luasnip.expand()
                  elseif luasnip.expand_or_jumpable() then
                      luasnip.expand_or_jump()
                  elseif check_backspace() then
                      fallback()
                  else
                      fallback()
                  end
              end
            '';
            modes = ["i" "s"];
          };
        };
      };
    };
  };
}
