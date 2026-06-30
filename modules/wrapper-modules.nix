# taken from parts.nix of nix-wrapper-modules
{
  lib,
  inputs,
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
          { options, ... }:
          {
            options.wrappers = mkOption {
              type = types.lazyAttrsOf (inputs.wrappers.lib.types.subWrapperModuleWith { });
              default = { };
            };
            options.wrapperModules = mkOption {
              type = types.lazyAttrsOf types.deferredModule;
              readOnly = true;
            };
            config.wrapperModules = (types.lazyAttrsOf types.deferredModule).merge options.wrappers.loc options.wrappers.definitionsWithLocations;
          }
        )
      ];
    };
  };
}
