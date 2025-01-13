{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./keymaps.nix
    ./options.nix
    ./plugins.nix
  ];
  options = {
    nixvim.enable = lib.mkEnableOption "enables nixvim";
  };
  config = lib.mkIf config.nixvim.enable {
    home.sessionVariables.EDITOR = "nvim";
    programs.nixvim = {
      enable = true;
      globals.mapleader = " ";
      autoCmd = [
        # Remove trailing whitespace on save
        {
          event = "BufWrite";
          command = "%s/\\s\\+$//e";
        }

        {
          event = [
            "BufEnter"
            "FocusGained"
          ];
          command = "checktime";
        }

        {
          event = "FileType";
          pattern = [
            "markdown"
            "text"
          ];
          command = "setlocal spell spelllang=en";
        }
      ];
      extraConfigLua = ''
        vim.keymap.set("ca", "W", "w")
        local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
        for type, icon in pairs(signs) do
          local hl = "DiagnosticSign" .. type
          vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end
      '';
    };
  };
}
