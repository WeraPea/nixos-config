{
  config,
  lib,
  ...
}:
{
  options.flake = {
    modules = lib.mkOption {
      type = lib.types.lazyAttrsOf (lib.types.lazyAttrsOf lib.types.deferredModule);
      default = { };
    };
    nixosModules = lib.mkOption { };
    # nixosModules = lib.mkOption { type = lib.types.attrsOf (lib.types.uniq lib.types.anything); };
  };
  config.flake.nixosModules = (
    lib.concatMapAttrs (
      name: value: lib.optionalAttrs (value ? nixos) { ${name} = value.nixos; }
    ) config.flake.modules
  );
}
