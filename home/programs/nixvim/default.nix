{
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
        vim.cmd([[
          cnoreabbrev <expr> W (getcmdtype() == ':' && getcmdline() =~ '^W$') ? 'w' : 'W'
        ]])
        vim.diagnostic.config({
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = " ",
              [vim.diagnostic.severity.WARN]  = " ",
              [vim.diagnostic.severity.HINT]  = "󰠠 ",
              [vim.diagnostic.severity.INFO]  = " ",
            },
        }})
      '';
    };
  };
}
