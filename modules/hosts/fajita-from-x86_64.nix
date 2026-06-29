{
  flake,
  lib,
  ...
}:
let
  moduleName = "_fajita-from-x86_64";
in
{
  flake.nixosConfigurations.${lib.removePrefix "_" moduleName} = flake.lib.mkNixosConfig moduleName;
  flake.modules.${moduleName}.nixos = {
    imports = [ flake.nixosModules._fajita ];
    werapi.buildSystem = "x86_64-linux";
  };
}
