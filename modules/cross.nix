{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  moduleName = "cross";
  cfg = config.werapi.${moduleName};
  pkgsX86_64 = import inputs.nixpkgs {
    system = "x86_64-linux";
  };
  cross =
    config.werapi.buildSystem == "x86_64-linux" && pkgs.stdenv.hostPlatform.system != "x86_64-linux";
  manPackage =
    if cross then
      pkgs.symlinkJoin {
        name = "man-with-x86_64-mandb";
        paths = [
          pkgs.man
          pkgsX86_64.man
        ];

        postBuild = ''
          rm -f $out/bin/mandb
          ln -s ${pkgsX86_64.man}/bin/mandb $out/bin/mandb
        '';
      }
    else
      pkgs.man;
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
    hm.programs.man.package = manPackage;
    documentation.man.man-db.package = manPackage;
    documentation.man.cache.generateAtRuntime = !cross;
  };
}
