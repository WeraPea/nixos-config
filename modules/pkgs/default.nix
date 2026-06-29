{
  flake,
  lib,
  ...
}:
{
  options.flake.packages = lib.mkOption {
    type = lib.types.lazyAttrsOf (lib.types.lazyAttrsOf lib.types.package);
  };
  config = {
    flake.packages = flake.lib.foreachSystem (
      system: flake.lib.importPackages flake.lib.pkgsBySystem.${system} ./_pkgs
    );
    flake.overlays.packages = (
      final: prev: {
        werapi = prev.werapi or { } // flake.packages.${final.stdenv.hostPlatform.system};
      }
    );
  };
}
