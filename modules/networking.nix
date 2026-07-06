let
  moduleName = "networking";
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
      options.werapi = {
        ${moduleName}.enable = lib.mkOption {
          default = config.werapi.defaultModules.enable;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
        hostname = lib.mkOption {
          description = "Sets hostname.";
          type = lib.types.str;
        };
        domain = lib.mkOption {
          description = "Sets domain.";
          type = lib.types.str;
        };
      };
      config = lib.mkIf cfg.enable {
        programs.mtr.enable = true;
        services.tailscale = {
          enable = true;
          extraSetFlags = [
            "--hostname=${config.networking.hostName}-ts"
          ];
        };
        networking = {
          hostName = config.werapi.hostname;
          networkmanager.enable = true;
        };
      };
    };
}
