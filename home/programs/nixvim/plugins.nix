{pkgs, ...}: {
  programs.nixvim.plugins = {
    comment-nvim.enable = true;
    undotree.enable = true;
    trouble.enable = true;
    which-key.enable = true;
    notify.enable = true;
    oil.enable = true;
    lastplace.enable = true;
    # yuck.enable = true;
    crates-nvim.enable = true;
    rust-tools.enable = true;
    lspkind.enable = true;
    cmp-nvim-lsp-signature-help.enable = true;
    cmp_luasnip.enable = true;
    luasnip.enable = true;
    gitsigns.enable = true;
    lualine.enable = true;
    illuminate.enable = true;
    todo-comments.enable = true;
    nix.enable = true;
    conform-nvim = {
      enable = true;
      formatOnSave = {
        timeoutMs = 500;
        lspFallback = true;
      };
      formattersByFt = {
        nix = ["alejandra"];
        rust = ["rustfmt"];
      };
    };
    treesitter = {
      enable = true;
      folding = true;
      indent = true;
      nixvimInjections = true;
    };
    nvim-colorizer = {
      enable = true;
      userDefaultOptions.names = false;
    };
    telescope = {
      enable = true;
      keymaps = {
        "<leader>ff" = "find_files";
        "<leader>fr" = "oldfiles";
        "<leader>gc" = "grep_string";
        "<leader>g" = "live_grep";
        "<leader>b" = "current_buffer_fuzzy_find";
        "<leader>m" = "marks";
        "<leader>h" = "help_tags";
        "<leader>d" = "diagnostics";
        "<leader>D" = "lsp_definitions";
        "<leader>c" = "commands";
        "<leader>C" = "command_history";
        "<leader>q" = "quickfix";
        "<leader>r" = "registers";
        "<leader>v" = "vim_options";
        "<leader>x" = "spell_suggest";
        "<leader>lr" = "lsp_references";
        "<leader>ls" = "lsp_document_symbols";
        "<leader>ld" = "diagnostics";
        "<leader>lD" = "lsp_definitions";
        "<leader>lt" = "lsp_type_definitions";
        "<leader><space>" = "buffers";
        # "<C-p>" = "git_files";
      };
      extraOptions.pickers.buffers = {
        show_all_buffers = "true";
        theme = "dropdown";
        mappings = {
          i = {
            "<c-d>" = "delete_buffer";
            "<c-k>" = "move_selection_previous";
            "<c-j>" = "move_selection_next";
          };
          n = {
            "dd" = "delete_buffer";
            "x" = "delete_buffer";
          };
        };
      };
      keymapsSilent = true;
      defaults = {
        file_ignore_patterns = [
          "^.git/"
          "^__pycache__/"
          "^output/"
        ];
        set_env.COLORTERM = "truecolor"; # ?????
      };
    };
    lsp = {
      enable = true;
      keymaps = {
        silent = true;
        diagnostic."<leader>d" = "open_float";

        lspBuf = {
          gd = "definition";
          gD = "declaration";
          gr = "references";
          gt = "type_definition";
          gi = "implementation";
          K = "hover";
          "<leader>r" = "rename";
          "<leader>a" = "code_action";
        };
      };
      servers = {
        # rust-analyzer.enable = true;
        lua-ls.enable = true;
        pylsp.enable = true;
        nixd.enable = true;
      };
      #    onAttach = ''
      #          opts = {silent = true, buffer = bufnr}
      # vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", )
      #    '';
    };
    nvim-cmp = {
      enable = true;
      sources = [
        {name = "nvim_lsp";}
        {name = "path";}
        {
          name = "buffer";
          # Words from other open buffers can also be suggested.
          option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
        }
        {name = "luasnip";}
        {name = "nvim_lsp_signature_help";}
      ];
      mapping = {
        "<Up>" = "cmp.mapping.select_prev_item()";
        "<Down>" = "cmp.mapping.select_next_item()";
        "<C-e>" = "cmp.mapping.abort()";
        "<C-CR>" = "cmp.mapping.confirm({ select = true })";
        "<CR>" = "cmp.mapping.confirm({ select = false })";
      };
    };
  };
  home.packages = with pkgs; [
    python311Packages.python-lsp-server
    lua-language-server
    vscode-langservers-extracted
    nixd
    rust-analyzer
  ];
}
