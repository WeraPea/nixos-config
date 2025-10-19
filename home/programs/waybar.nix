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
    programs.waybar =
      with config.lib.stylix.colors.withHashtag;
      let
        white = base05;
      in
      {
        enable = lib.mkDefault true;
        systemd.enable = true;
        settings =
          let
            general_settings = {
              mpd =
                let
                  mpc = lib.getExe pkgs.mpc;
                in
                {
                  format = "{artist} - {title}";
                  on-click = "${mpc} toggle";
                  on-click-right = lib.getExe pkgs.cantata;
                  on-scroll-up = "${mpc} vol +1";
                  on-scroll-down = "${mpc} vol -1";
                  artist-len = 30;
                  title-len = 40;
                };
              temperature = {
                hwmon-path = "/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon6/temp3_input";
                critical-threshold = 80;
              };
              "dwl/tags" = {
                num-tags = 9;
              };
              "dwl/window" = {
                format = "[{layout}] {title}";
              };
              tray = {
                spacing = 4;
              };
              clock = {
                tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
                format-alt = "{:%Y-%m-%d}";
                calendar.format.today = "<span background='${cyan}' foreground='${base00}'><b>{}</b></span>";
              };
              wireplumber = {
                format-muted = "muted {volume}%";
                max-volume = 150;
                on-click-right = lib.getExe pkgs.pwvucontrol;
                on-click = "${lib.getExe pkgs.pamixer} -t";
                # on-click-middle = "pulseaudio-control --node-blacklist audiorelay-virtual-mic-sink,audiorelay_Speaker next-node", # TODO:
              };
              "custom/prusa" = {
                format = "{}";
                exec =
                  let
                    prusa-status =
                      pkgs.writers.writePython3Bin "prusa_status" { libraries = [ pkgs.python3Packages.requests ]; }
                        ''
                          import os
                          import time
                          import requests
                          from pathlib import Path
                          from datetime import datetime, timedelta
                          from requests.auth import HTTPDigestAuth

                          config_dir = os.getenv("XDG_CONFIG_HOME", str(Path.home() / ".config"))
                          auth_file_path = Path(config_dir) / "prusa_auth"

                          try:
                              with open(auth_file_path, "r") as f:
                                  lines = f.readlines()
                                  username = lines[0].strip()
                                  password = lines[1].strip()
                          except FileNotFoundError:
                              raise FileNotFoundError(f"Auth file not found at {auth_file_path}")
                          except IndexError:
                              raise ValueError("Auth file is missing username or password.")

                          url = "http://192.168.1.16/api/v1/job"

                          while True:
                              try:
                                  response = requests.get(url, auth=HTTPDigestAuth(username, password))
                              except requests.exceptions.RequestException:
                                  time.sleep(60)
                                  continue

                              if response.status_code == 200:
                                  data = response.json()

                                  time_remaining = data.get('time_remaining', 0)
                                  file = data.get('file', {}).get('display_name', "")

                                  current_time = datetime.now()
                                  expected_end_time = current_time + timedelta(seconds=time_remaining)

                                  remaining_time_delta = timedelta(seconds=time_remaining)
                                  human_readable_parts = []

                                  time_delta = timedelta(seconds=time_remaining)
                                  days = time_delta.days
                                  hours, remainder = divmod(time_delta.seconds, 3600)
                                  minutes = remainder // 60

                                  if days > 0:
                                      human_readable_parts.append(f"{days}d")
                                  if hours > 0:
                                      human_readable_parts.append(f"{hours}h")
                                  if minutes > 0:
                                      human_readable_parts.append(f"{minutes}m")

                                  human_readable = " ".join(human_readable_parts) \
                                      if human_readable_parts else "0m"

                                  expected_end_delta = timedelta(seconds=time_remaining)
                                  end_days = expected_end_delta.days

                                  expected_end_days = f"in {end_days} days " if end_days > 0 else ""

                                  print(f"ETA: {human_readable} {expected_end_days}at "
                                        f"{expected_end_time.strftime('%H:%M')}", flush=True)
                              else:
                                  print("", flush=True)
                              time.sleep(60)
                        '';
                  in
                  lib.getExe prusa-status;
              };
            };
          in
          {
            mainbar = {
              layer = "top";
              height = 20;
              spacing = 4;
              modules-left = [
                "dwl/tags"
                "dwl/window"
              ];
              modules-right = [
                "temperature"
                "custom/prusa"
                "mpd"
                "wireplumber"
                "clock"
                "tray"
              ];
            }
            // general_settings;
          };
        style =
          # css
          ''
            * {
              font-family: "${config.stylix.fonts.monospace.name}";
              font-weight: bold;
              margin-bottom: -1;
              margin-top: -1;
              border: none;
              border-radius: 0;
              font-size: 14px;
            }
            window#waybar {
              background-color: transparent;
              color: ${white};
              transition-property: background-color;
              transition-duration: .5s;
            }
            #tags button {
              color: ${white};
              padding: 1px;
            }
            #tags button.occupied {
              color: ${cyan};
            }
            #tags button.focused {
              box-shadow: inset 0 -6px ${cyan};
            }
            #tags button.urgent {
              background-color: ${red};
            }
            #mpd.paused {
              color: ${base02};
            }
            #temperature.critical {
              color: ${red};
            }
          '';
      };
  };
}
