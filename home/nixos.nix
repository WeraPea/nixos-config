{
  inputs,
  pkgs,
  ...
}:
{

  home-manager = {
    sharedModules = [
      inputs.hyprland.homeManagerModules.default
      {
        home = {
          username = "wera";
          homeDirectory = "/home/wera";
          stateVersion = "23.11";
        };
        quickshell.enable = true;
        systemd.user.services.overscan-workaround = {
          Unit = {
            Description = "Overscan workaround";
            After = [ "graphical-session.target" ];
            Requires = [ "graphical-session.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.writeShellScript "overscan-wakeup" ''
              set -e
              if ! pgrep -u "$UID" -x wl-present >/dev/null; then
                hyprctl output create headless SAMSUNG_OVERSCAN_WORKAROUND # running this multiple times is fine
                ${pkgs.wl-mirror}/bin/wl-present mirror SAMSUNG_OVERSCAN_WORKAROUND
              fi
            ''}";
            Restart = "always"; # reason: stops after suspend
            RestartSec = 5;
          };
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
        };
        wayland.windowManager.hyprland.settings.monitor =
          let
            resX = 1920;
            resY = 1080;
            offsetTop = 24;
            offsetBottom = 25;
            offsetLeft = 97;
            offsetRight = 97; # "half" a pixel is still visible when set to 96
            resX2 = resX - offsetLeft - offsetRight;
            resY2 = resY - offsetTop - offsetBottom;
          in
          [
            "DP-2,2560x1440@144,0x0,auto"
            "HDMI-A-1,1280x1024@75,2560x0,auto"
            "HDMI-A-2,${toString resX}x${toString resY}@60,0x-3000,1"
            "HDMI-A-2,addreserved,${toString offsetTop},${toString offsetBottom},${toString offsetLeft},${toString offsetRight}"
            "SAMSUNG_OVERSCAN_WORKAROUND,${toString resX2}x${toString resY2}@60,-${toString resX2}x${toString <| 1440 - resY2},1"
          ];
      }
    ];
    users.wera = import ./home.nix;
  };
}
