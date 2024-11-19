{
  pkgs,
  config,
  osConfig,
  ...
}:
{
  programs.nixvim.plugins = {
    web-devicons.enable = true;
    cmp_luasnip.enable = true;
    cmp-nvim-lsp-signature-help.enable = true;
    comment.enable = true;
    crates-nvim.enable = true;
    gitsigns.enable = true;
    illuminate.enable = true;
    lastplace.enable = true;
    lspkind.enable = true;
    lualine.enable = true;
    luasnip.enable = true;
    nix.enable = true;
    notify.enable = true;
    oil.enable = true;
    rust-tools.enable = true;
    todo-comments.enable = true;
    trouble.enable = true;
    undotree.enable = true;
    which-key.enable = true;
    openscad = {
      enable = true;
      keymaps = {
        enable = true;
        cheatsheetToggle = "<C-c>";
      };
    };
    instant = {
      enable = true;
      settings = {
        username = "werapi";
      };
    };
    conform-nvim = {
      enable = true;
      settings = {
        format_on_save = {
          timeoutMs = 500;
          lspFallback = true;
        };
        formatters_by_ft = {
          nix = [ "nixfmt" ];
          rust = [ "rustfmt" ];
        };
      };
    };
    treesitter = {
      enable = true;
      folding = true;
      nixvimInjections = true;
      settings = {
        indent.enable = true;
      };
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
        "<leader>gg" = "live_grep";
        "<leader>gb" = "current_buffer_fuzzy_find";
        "<leader>m" = "marks";
        "<leader>h" = "help_tags";
        "<leader>d" = "diagnostics";
        "<leader>D" = "lsp_definitions";
        "<leader>c" = "commands";
        "<leader>C" = "command_history";
        "<leader>q" = "quickfix";
        # "<leader>r" = "registers";
        "<leader>v" = "vim_options";
        "<leader>x" = "spell_suggest";
        "<leader>lr" = "lsp_references";
        "<leader>ls" = "lsp_document_symbols";
        "<leader>ld" = "diagnostics";
        "<leader>lD" = "lsp_definitions";
        "<leader>lt" = "lsp_type_definitions";
        "<leader>b" = "buffers";
        # "<C-p>" = "git_files";
      };
      settings.pickers.buffers = {
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
      settings.defaults = {
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
        # pylsp = {
        #   enable = true;
        #   settings.plugins = {
        #     black.enabled = true;
        #     flake8.enabled = true;
        #     pylint.enabled = true;
        #     ruff.enabled = true;
        #     rope.enabled = true;
        #   };
        # };
        # clangd.enable = true;
        nixd = {
          enable = true;
          settings = {
            formatting.command = [ "nixfmt" ];
            options = {
              nixos.expr = "(builtins.getFlake (\"${config.home.homeDirectory}/nixos-config\")).nixosConfigurations.${osConfig.system.name}.options";
            };
          };
        };
        lua_ls.enable = true;
        pyright.enable = true;
        ccls.enable = true;
      };
    };
    cmp = {
      enable = true;
      settings = {
        mapping = {
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-d>" = "cmp.mapping.scroll_docs(-4)";
          "<C-e>" = "cmp.mapping.close()";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          "<Up>" = "cmp.mapping.select_prev_item()";
          "<Down>" = "cmp.mapping.select_next_item()";
        };
        snippet = {
          expand = "luasnip";
        };
        sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          {
            name = "buffer";
            # Words from other open buffers can also be suggested.
            option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
          }
          { name = "luasnip"; }
          { name = "nvim_lsp_signature_help"; }
        ];
      };
    };
  };
  home.packages = with pkgs; [
    clang
    lua-language-server
    nixd
    rust-analyzer
    vscode-langservers-extracted
  ];
}
