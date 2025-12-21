{
  pkgs,
  config,
  osConfig,
  lib,
  ...
}:
{
  programs.nixvim.plugins = {
    web-devicons.enable = true;
    cmp_luasnip.enable = true;
    cmp-nvim-lsp-signature-help.enable = true;
    comment.enable = true;
    crates.enable = true;
    gitsigns.enable = true;
    # illuminate.enable = true; # causes a hang in some situations, investigate further?
    lastplace.enable = true;
    lspkind.enable = true;
    lualine.enable = true;
    luasnip.enable = true;
    nix.enable = true;
    notify.enable = true;
    oil.enable = true; # file explorer
    rustaceanvim.enable = true;
    todo-comments.enable = true;
    trouble.enable = true;
    undotree.enable = true;
    which-key.enable = true;
    treesitter-context.enable = true;
    markdown-preview.enable = true;
    nvim-surround.enable = true;
    rainbow-delimiters.enable = true;
    otter.enable = true; # nested lsp
    git-conflict.enable = true;
    neogit.enable = true;
    vim-suda = {
      enable = true;
      settings.smart_edit = 1;
    };
    openscad = {
      enable = true;
      settings = {
        cheatsheet-toggle-key = "<C-c>";
      };
    };
    conform-nvim = {
      enable = true;
      luaConfig.post = ''
        vim.keymap.set('n', '<leader>fm', function()
          require('conform').format({ lsp_fallback = true })
        end, { desc = 'Format with conform' })
      '';
      settings = {
        format_on_save = { };
        formatters_by_ft = {
          nix = [ "nixfmt" ];
          rust = [ "rustfmt" ];
          bash = [
            "shellcheck"
            "shellharden"
            "shfmt"
          ];
          sh = [
            "shellcheck"
            "shellharden"
            "shfmt"
          ];
        };
        formatters = {
          nixfmt = {
            command = lib.getExe pkgs.nixfmt-rfc-style;
          };
          shellcheck = {
            command = lib.getExe pkgs.shellcheck;
          };
          shfmt = {
            command = lib.getExe pkgs.shfmt;
          };
          shellharden = {
            command = lib.getExe pkgs.shellharden;
          };
        };
      };
    };
    treesitter = {
      enable = true;
      folding = true;
      nixvimInjections = true;
      settings = {
        ensureInstalled = "all";
        indent.enable = true;
        highlight.enable = true;
      };
    };
    colorizer = {
      enable = true;
      settings.user_default_options.names = false;
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
        "<leader>x" = "spell_suggest";
        "<leader>lr" = "lsp_references";
        "<leader>ls" = "lsp_document_symbols";
        "<leader>ld" = "diagnostics";
        "<leader>lD" = "lsp_definitions";
        "<leader>lt" = "lsp_type_definitions";
        "<leader>b" = "buffers";
        # "<C-p>" = "git_files";
      };
      settings.pickers = {
        find_files = {
          no_ignore = true;
          hidden = true;
          follow = true;
        };
        live_grep = {
          additional_args = [
            "--hidden"
            "--no-ignore"
            "--follow"
          ];
        };
        grep_string = {
          additional_args = [
            "--hidden"
            "--no-ignore"
            "--follow"
          ];
        };
        buffers = {
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
        nixd = {
          enable = true;
          settings = {
            formatting.command = [ "nixfmt" ];
            options = {
              nixos.expr = "(builtins.getFlake (\"${config.home.homeDirectory}/nixos-config\")).nixosConfigurations.${osConfig.system.name}.options";
            };
          };
        };
        qmlls.enable = true;
        lua_ls.enable = true;
        pyright.enable = true;
        ccls.enable = true;
        # clangd.enable = true;
        gopls.enable = true;
      };
    };
    cmp = {
      enable = true;
      settings = {
        mapping = {
          "<C-Space>" = ''cmp.mapping.complete()'';
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
}
