let
  moduleName = "nix-search-tv";
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
        environment.systemPackages = [
          (pkgs.writeShellApplication {
            name = "ntv";
            runtimeInputs = with pkgs; [
              fzf
              nix-search-tv
            ];
            checkPhase = ""; # Ignore the shell checks
            text = builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh";
          })
        ];
      };
    };
}
