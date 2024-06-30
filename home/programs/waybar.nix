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
    stylix.targets.waybar.enable = false;
    programs.waybar = {
      enable = lib.mkDefault true;
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
            # "custom/audiorelay"
            # "temperature"
            "custom/spotify"
            "wireplumber"
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
            on-click-right = lib.getExe pkgs.pavucontrol;
            on-click = "${lib.getExe pkgs.pamixer} -t";
            # on-click-middle = "pulseaudio-control --node-blacklist audiorelay-virtual-mic-sink,audiorelay_Speaker next-node", # TODO:
          };
          "custom/spotify" = {
            format = "{}";
            # return-type = "json";
            max-length = 40;
            on-click = "${lib.getExe pkgs.playerctl} -p spotify play-pause";
            escape = true;
            on-scroll-up = "playerctl -p spotify volume 0.01+";
            on-scroll-down = "playerctl -p spotify volume 0.01-";
            exec =
              let
                spotify-status = pkgs.writeShellScriptBin "spotify-status" ''
                  while true; do
                    status=$(${lib.getExe pkgs.playerctl} -p spotify status 2>/dev/null)
                    if [[ "$status" == "Playing" ]]; then
                      playing=""
                    else
                      playing=""
                    fi
                    if [[ "$status" != "" ]]; then
                      echo $playing $(${lib.getExe pkgs.playerctl} -p spotify metadata xesam:title) - $(${lib.getExe pkgs.playerctl} -p spotify metadata xesam:artist)
                    else
                      echo
                      sleep 5
                    fi
                    sleep 0.5 # bit overly expensive on cpu for what it does
                  done
                '';
              in
              lib.getExe spotify-status;
          };
          # "custom/audiorelay" = {
          #   format = "{}";
          #   return-type = "json";
          #   exec = "$HOME/rust/waybar-audiorelay/target/release/waybar-audiorelay"; # TODO:
          # };
        };
      };
      style = # css
        ''
          * {
              font-family: "JetbrainsMono NFM", "Noto Sans CJK JP";
              margin-bottom: -1;
              margin-top: -1;
              border: none;
          }

          window#waybar {
              font-size: 14px;
              /* background-color: #121212; */
              background-color: transparent;
              color: #d0d0d0;
              transition-property: background-color;
              transition-duration: .5s;
          }

          window#waybar.steam {
              background-color: #171D25;
              border: none;
          }
          #workspaces button {
              color: #d0d0d0;
          }

          #workspaces button:hover {
              box-shadow: inset 0 -6px #d0d0d0;
          }

          #workspaces button.active {
              box-shadow: inset 0 -6px #d0d0d0;
          }

          #workspaces button.urgent {
              background-color: #eb4d4b;
          }

          #pulseaudio.muted {
              background-color: #90b1b1;
              color: #2a5c45;
          }

          #custom-spotify {
              color: #1ED760;
          }

          #custom-spotify.Paused {
              color: #505050;
          }

          #custom-audiorelay.running {
              background-color: #eb4d4b;
          }
        '';
    };
  };
}
