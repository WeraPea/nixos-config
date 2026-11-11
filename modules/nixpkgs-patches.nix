{ lib, flake, ... }:
{
  options.flake = {
    nixpkgs = lib.mkOption { };
    nixpkgs-patches = lib.mkOption {
      type = lib.types.lazyAttrsOf (lib.types.functionTo lib.types.pathInStore);
      default = { };
      example = lib.literalExpression "{ my-patch = pkgs: pkgs.fetchPatch { ... }; }";
    };
  };
  config = {
    flake.nixpkgs =
      args:
      let
        pkgs0 = import flake.inputs.nixpkgs args;
        nixpkgs = pkgs0.applyPatches {
          name = "source";
          src = pkgs0.path;
          patches = lib.mapAttrsToList (name: value: value pkgs0) flake.nixpkgs-patches;
        };
        pkgs = if flake.nixpkgs-patches == { } then pkgs0 else import nixpkgs args;
      in
      pkgs;
    flake.modules.nixpkgs-patches.nixos =
      {
        config,
        lib,
        ...
      }:
      {
        options.werapi.nixpkgs.config = lib.mkOption { default = { }; };
        config.nixpkgs.pkgs =
          let
            isCross = config.nixpkgs.buildPlatform != config.nixpkgs.hostPlatform;
          in
          flake.nixpkgs (
            (
              if isCross then
                {
                  localSystem = config.nixpkgs.buildPlatform;
                  crossSystem = config.nixpkgs.hostPlatform;
                }
              else
                {
                  localSystem = config.nixpkgs.hostPlatform;
                }
            )
            // {
              inherit (config.werapi.nixpkgs) config;
            }
          );
      };
  };
}
