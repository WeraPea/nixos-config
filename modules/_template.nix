{
  config,
  inputs,
  lib,
  outputs,
  pkgs,
  ...
}:
let
  moduleName = "";
  cfg = config.werapi.${moduleName};
  hmConfig = config.home-manager.users.${config.werapi.username};
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
  };
}
