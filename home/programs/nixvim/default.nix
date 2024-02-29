{...}: {
  programs.nixvim = {
    enable = true;
    globals.mapleader = " ";
    options = {
      clipboard = "unnamedplus";
      cursorline = true;
      expandtab = true;
      foldenable = false;
      lazyredraw = true;
      linebreak = true;
      listchars = "nbsp:¬,trail:•,space:•,tab:-->";
      mouse = "a";
      number = true;
      scrolloff = 8;
      shiftwidth = 4;
      showmode = false;
      sidescrolloff = 8;
      smartcase = true;
      ignorecase = true;
      smartindent = true;
      splitbelow = true;
      splitright = true;
      tabstop = 4;
      termguicolors = true;
      undofile = true;
      updatetime = 300;
      writebackup = false;
    };
    plugins = {
      # lightline.enable = true;
      comment-nvim.enable = true;
      oil.enable = true;
      treesitter.enable = true;
      luasnip.enable = true;
      gitsigns.enable = true;
      lualine.enable = true;
      lsp = {
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
