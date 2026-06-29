{ lib, flake, ... }:
{
  options.flake.lib = lib.mkOption { };
  config.flake.lib = rec {
    foreachSystem = f: lib.genAttrs flake.settings.systems f;
    pkgsBySystem = foreachSystem (
      system:
      import flake.inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = publicAttrValues flake.overlays;
      }
    );
    underscorePrefix = s: if builtins.match "[0-9].*" s != null then "_${s}" else s;
    nameFromPath = path: underscorePrefix (lib.removeSuffix ".nix" (baseNameOf path));
    pathsToAttrs =
      mapFunc: paths:
      builtins.listToAttrs (
        map (path: {
          name = nameFromPath path;
          value = mapFunc path;
        }) paths
      );
    importTree = paths: import ./_import-tree.nix lib paths;
    mkNixosConfig =
      hostModuleName:
      lib.nixosSystem {
        modules = [ flake.nixosModules.${hostModuleName} ] ++ publicAttrValues flake.nixosModules;
      };
    importPackages = pkgs: path: pathsToAttrs (path': pkgs.callPackage path' { }) (importTree path);
    publicAttrValues =
      attr: builtins.attrValues (lib.filterAttrs (name: _: !lib.hasPrefix "_" name) attr);
  };
}
