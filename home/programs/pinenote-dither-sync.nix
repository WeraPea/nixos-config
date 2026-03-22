{
  lib,
  pkgs,
  config,
  outputs,
  ...
}:

let
  cfg = config.pinenote-dither-sync;
  pinenote-dither-sync = outputs.packages.${pkgs.stdenv.hostPlatform.system}.pinenote-dither-sync;
in
{
  options.pinenote-dither-sync = {
    enable = lib.mkEnableOption "pinenote-dither-sync";
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.pinenote-dither-sync = {
      Unit = {
        Description = "pinenote-dither-sync";
        After = [
          "graphical-session.target"
          "pinenote.service"
        ];
        BindsTo = [ "pinenote.service" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = lib.getExe pinenote-dither-sync;
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
