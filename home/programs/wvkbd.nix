{
  lib,
  pkgs,
  config,
  ...
}:
let
  wvkbd-filter-activate = pkgs.writeShellScript "wvkbd-filter-activate" ''
    if [ "$1" = "activate" ]; then
      grep -Fxq "$(hyprctl -j activewindow | jq -r '.class')" ~/.config/wvkbd/blacklist && exit
      pkill -SIGUSR2 wvkbd
    elif [ "$1" = "deactivate" ]; then
      pkill -SIGUSR1 wvkbd
    else
      echo "Usage: $0 [activate|deactivate]"
      exit 1
    fi
  '';
in
{
  options = {
    wvkbd.enable = lib.mkEnableOption "Enables wvkbd";
    wvkbd.blacklist = lib.mkOption {
      description = "List of Hyprland client classes for which the virtual keyboard will not automatically show. Not used during deactivation.";
      type = lib.types.listOf lib.types.str;
      default = [ "KOReader" ];
    };
  };
  config = lib.mkIf config.wvkbd.enable {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        addons = [
          pkgs.virtualkeyboard-adapter
        ];
        settings.addons = {
          virtualkeyboardadapter.globalSection.ActivateCmd = ''"${wvkbd-filter-activate} activate"'';
          virtualkeyboardadapter.globalSection.DeactivateCmd = ''"${wvkbd-filter-activate} deactivate"'';
        };
      };
    };
    xdg.configFile."wvkbd/blacklist".text = lib.concatStringsSep "\n" config.wvkbd.blacklist;
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
