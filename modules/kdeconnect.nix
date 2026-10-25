let
  moduleName = "kdeconnect";
in
{
  flake.modules.${moduleName}.nixos =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.werapi.${moduleName};
    in
    {
      options.werapi.${moduleName} = {
        enable = lib.mkOption {
          default = false;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
      };
      config = lib.mkIf cfg.enable {
        programs.kdeconnect.enable = true;
        hm.services.kdeconnect = {
          enable = true;
          indicator = true;
        };
      };
    };
}
