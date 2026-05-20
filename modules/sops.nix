{
  config,
  inputs,
  lib,
  ...
}:
let
  moduleName = "sops";
  cfg = config.werapi.${moduleName};
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  options.werapi.${moduleName} = {
    enable = lib.mkOption {
      default = config.werapi.defaultModules.enable;
      description = "Whether to enable ${moduleName}.";
      type = lib.types.bool;
    };
  };
  config = lib.mkIf cfg.enable {
    sops = {
      defaultSopsFormat = "yaml";
      age.keyFile = "/home/${config.werapi.username}/.config/sops/age/keys.txt";
      defaultSopsFile = "/etc/sops/secrets.yaml";
      validateSopsFiles = false;
    };
  };
}
