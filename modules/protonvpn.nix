{
  inputs,
  ...
}:
let
  moduleName = "protonvpn";
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
      imports = [
        inputs.erosanix.nixosModules.protonvpn
      ];
      options.werapi.${moduleName} = {
        enable = lib.mkOption {
          default = config.werapi.defaultModules.enable;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
      };
      config = lib.mkIf cfg.enable {
        services.protonvpn = {
          enable = true;
          autostart = false;
          interface.privateKeyFile = "/etc/protonvpn";
          endpoint = {
            publicKey = "9Yy7/zeaFvKd/ETcLg0PvsJb5PVMj9dX4Wg7NVNVbCs=";
            ip = "149.88.103.48";
            port = 51820;
          };
        };
      };
    };
}
