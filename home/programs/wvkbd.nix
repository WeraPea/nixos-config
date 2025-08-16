{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
{
  options = {
    wvkbd.enable = lib.mkEnableOption "enables wvkbd";
  };
  config = lib.mkIf config.wvkbd.enable {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        addons = [
          inputs.fcitx-virtualkeyboard-adapter.packages.${pkgs.system}.virtualkeyboard-adapter
        ];
        settings.addons = {
          virtualkeyboardadapter.globalSection.ActivateCmd = ''"pkill -SIGUSR2 wvkbd"'';
          virtualkeyboardadapter.globalSection.DeactivateCmd = ''"pkill -SIGUSR1 wvkbd"'';
        };
      };
    };
    systemd.user.services.wvkbd = {
      Unit = {
        Description = "wvkbd";
        Wants = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = pkgs.writeShellScript "wvkbd-hidden" "${lib.getExe pkgs.wvkbd} --hidden";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
