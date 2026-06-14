{
  config,
  lib,
  pkgs,
  ...
}:
let
  moduleName = "pinenote-dither-sync";
  cfg = config.werapi.${moduleName};
  pinenote-dither-sync = pkgs.werapi.pinenote-dither-sync;
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
    systemd.user.services.pinenote-dither-sync = {
      description = "pinenote-dither-sync";
      after = [
        "graphical-session.target"
        "pinenote.service"
      ];
      bindsTo = [ "pinenote.service" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = lib.getExe pinenote-dither-sync;
        Restart = "on-failure";
      };
      wantedBy = [ "graphical-session.target" ];
    };
  };
}
