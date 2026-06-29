{
  inputs,
  ...
}:
let
  moduleName = "nixvim";
in
{
  flake.modules.${moduleName}.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.werapi.${moduleName};
    in
    {
      options.werapi.${moduleName} = {
        enable = lib.mkOption {
          default = config.werapi.defaultModules.enable;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
      };
      config = lib.mkIf cfg.enable {
        home-manager.sharedModules = [
          inputs.nixvim.homeModules.nixvim
        ];
        hm = {
          home.sessionVariables.EDITOR = "nvim";
          programs.nixvim = {
            enable = true;
            globals.mapleader = " ";
            nixpkgs.config.allowUnfree = true;
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
            extraPlugins = [
              pkgs.vimPlugins.nvim_context_vt
            ];
            extraConfigLua = ''
              vim.g.clipboard = 'osc52'
              vim.cmd([[
                cnoreabbrev <expr> W (getcmdtype() == ':' && getcmdline() =~ '^W$') ? 'w' : 'W'
                cnoreabbrev <expr> Wq (getcmdtype() == ':' && getcmdline() =~ '^Wq$') ? 'wq' : 'Wq'
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
              require('nvim_context_vt').setup({
                prefix = '',
              })
            '';
          };
        };
      };
    };
}
