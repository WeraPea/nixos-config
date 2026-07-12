{
  inputs,
  ...
}:
let
  moduleName = "shell";
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
      imports = [
        inputs.nix-index-database.nixosModules.default
      ];
      options.werapi.${moduleName} = {
        enable = lib.mkOption {
          default = config.werapi.defaultModules.enable;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
      };
      config = lib.mkIf cfg.enable {
        environment.shellAliases = {
          cp = "cp -rip";
          mv = "mv -i";
          rm = "rm -i";
          cl = "clear";
          dc = "cd";
          lc = "clear";
          ls = "ll";
          sl = "ll";
          vim = "nvim";
          vm = "mv";
          x = "exit";
          ll = "eza -l";
          la = "eza -a";
          lla = "eza -la";
          lt = "eza --tree";
          eza = "eza --icons auto --git --group-directories-first";
        };
        environment.systemPackages = [
          pkgs.eza
        ];
        programs = {
          bash.enable = true;
          bat = {
            enable = true;
            extraPackages = with pkgs.bat-extras; [
              batdiff
              batwatch
            ];
            settings.paging = "never";
          };
          direnv = {
            enable = true;
            nix-direnv.enable = true;
          };
          nix-index-database.comma.enable = true;
        };
      };
    };
}
