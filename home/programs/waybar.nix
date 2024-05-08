{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    waybar.enable = lib.mkEnableOption "Enable waybar";
  };

  config = lib.mkIf config.waybar.enable {
    stylix.targets.waybar.enable = lib.mkIf config.programs.waybar.enable false;
    programs.waybar = {
      enable = lib.mkDefault true;
      systemd.enable = true;
      settings = {
        bar = {
          layer = "top";
          height = 20;
          spacing = 4;
          modules-left = [
            "hyprland/workspaces"
            "hyprland/window"
          ];
          modules-right = [
            "custom/audiorelay"
            "temperature"
            "wireplumber"
            "custom/spotify"
            "clock"
            "tray"
          ];
          "hyprland/window" = {
            max-length = 200;
            separate-outputs = true;
          };
          "hyprland/workspaces" = {
            format = "{name}";
          };
          tray = {
            spacing = 4;
          };
          clock = {
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            format-alt = "{:%Y-%m-%d}";
          };
          wireplumber = {
            format-muted = "muted {volume}%";
            max-volume = 150;
            on-click-right = "pavucontrol";
            on-click = "pamixer -t";
            # on-click-middle = "pulseaudio-control --node-blacklist audiorelay-virtual-mic-sink,audiorelay_Speaker next-node", TODO:
          };
          "custom/spotify" = {
            format = "{}";
            return-type = "json";
            max-length = 40;
            on-click = "playerctl -p spotify play-pause";
            escape = true;
            exec = "$HOME/.config/waybar/mediaplayer.py --player spotify 2> /dev/null"; # TODO:
          };
          "custom/audiorelay" = {
            format = "{}";
            return-type = "json";
            exec = "$HOME/rust/waybar-audiorelay/target/release/waybar-audiorelay"; # TODO:
          };
        };
      };
    };
  };
}
