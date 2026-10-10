{
  lib,
  flake,
  ...
}:
let
  inherit (lib) types mkOption;
in
{
  options.flake = mkOption {
    type = types.submoduleWith {
      modules = [
        (
          {
            config,
            ...
          }:
          {
            options.devshells = mkOption {
              type = types.lazyAttrsOf (types.functionTo types.package);
              default = { };
            };
            options.devShells = mkOption {
              type = types.lazyAttrsOf (types.lazyAttrsOf types.package);
              readOnly = true;
            };
            config.devShells = flake.lib.foreachSystem (
              system:
              let
                pkgs = flake.lib.pkgsBySystem.${system};
              in
              builtins.mapAttrs (_: value: pkgs.callPackage value { }) config.devshells
            );
          }
        )
      ];
    };
  };
}
