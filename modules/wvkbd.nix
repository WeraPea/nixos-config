{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  moduleName = "wvkbd";
  cfg = config.werapi.${moduleName};
  wvkbd-filter-activate = pkgs.writeShellScript "wvkbd-filter-activate" ''
    if [ "$1" = "activate" ]; then
      grep -Fxq "$(mmsg get all-monitors | ${lib.getExe pkgs.jq} -r 'monitors[] | select(.active) | .active_client.appid')" ~/.config/wvkbd/blacklist && exit
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
  options.werapi.${moduleName} = {
    enable = lib.mkOption {
      default = false;
      description = "Whether to enable ${moduleName}.";
      type = lib.types.bool;
    };
    blacklist = lib.mkOption {
      default = [ "KOReader" ];
      description = "List of client appids for which the virtual keyboard will not automatically show. Not used during deactivation.";
      type = lib.types.listOf lib.types.str;
    };
  };
  config = lib.mkIf cfg.enable {
    hm = {
      i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5 = {
          addons = [
            (pkgs.callPackage "${inputs.fcitx-virtualkeyboard-adapter}/virtualkeyboard-adapter.nix" { }) # no aarch64-linux in flake
          ];
          settings.addons.virtualkeyboardadapter.globalSection = {
            ActivateCmd = ''"${wvkbd-filter-activate} activate"'';
            DeactivateCmd = ''"${wvkbd-filter-activate} deactivate"'';
          };
        };
      };
      xdg.configFile."wvkbd/blacklist".text = lib.concatStringsSep "\n" cfg.blacklist;
      systemd.user.services.wvkbd = {
        Unit = {
          Description = "wvkbd";
          Wants = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart =
            with config.lib.stylix.colors;
            pkgs.writeShellScript "wvkbd-hidden" ''
              ${lib.getExe pkgs.wvkbd} --hidden \
                  --bg ${base00}\
                  --fg ${base02}\
                  --fg-sp ${base01}\
                  --press ${base03}\
                  --press-sp ${base03}\
                  --text ${base07}\
                  --text-sp ${base07}\
                  --fn "${config.stylix.fonts.sansSerif.name}"\
                  -R 0 -H 500'';
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
  };
}
