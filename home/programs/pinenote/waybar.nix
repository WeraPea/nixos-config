# based on waybar config by hrdl
{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  cycle-driver-mode = lib.getExe (
    pkgs.writers.writePython3Bin "cycle_driver_mode" {
      libraries = [ inputs.pinenote-nixos-follows.packages.${pkgs.system}.rockchip-ebc-custom-ioctl ];
      doCheck = false;
    } "import rockchip_ebc_custom_ioctl as reci; reci.cycle_driver_mode()"
  );
  toggle-onscreen-keyboard = lib.getExe' (pkgs.python3Packages.buildPythonApplication {
    pname = "toggle-onscreen-keyboard";
    version = "1.0";
    format = "other";

    src = pkgs.writeTextFile {
      name = "toggle-onscreen-keyboard";
      text = ''
        #!/usr/bin/env python3
        from pydbus import SessionBus
        import os
        import time

        bus = SessionBus()

        try:
            okb = bus.get("sm.puri.OSK0")
        except Exception:
            os.system("${lib.getExe' pkgs.coreutils "nohup"} ${lib.getExe' pkgs.squeekboard "squeekboard"} &")
            time.sleep(1)
            okb = bus.get("sm.puri.OSK0")

        okb.SetVisible(not okb.Visible)
      '';
    };
    dontUnpack = true;
    nativeBuildInputs = [ pkgs.wrapGAppsHook3 ];
    propagatedBuildInputs = [ pkgs.python3Packages.pydbus ];
    dontWrapGApps = true;
    installPhase = ''
      mkdir -p $out/bin
      install -m755 $src $out/bin/toggle-onscreen-keyboard
    '';
    preFixup = ''makeWrapperArgs+=("''${gappsWrapperArgs[@]}") '';
  }) "toggle-onscreen-keyboard";
  sway-workspace = lib.getExe (
    pkgs.writeShellScriptBin "sway-workspace" ''
      set -ef

      ws=$(swaymsg -t get_workspaces | jq '.[] | select((.output == "DPI-1") and .focused) | .num')
      if [[ $2 == "next" ]]; then
      	new_ws="$(echo "$ws" | tr 123 231)"
      	if [[ $1 == "goto" ]]; then
      		swaymsg workspace "$new_ws"
      	elif [[ $1 == "move" ]]; then
      		swaymsg move window to workspace "$new_ws"
      	fi
      elif [[ $2 == "prev" ]]; then
      	new_ws="$(echo "$ws" | tr 123 312)"
      	if [[ $1 == "goto" ]]; then
      		swaymsg workspace "$new_ws"
      	elif [[ $1 == "move" ]]; then
      		swaymsg move window to workspace "$new_ws"
      	fi
      else
      	exit 1
      fi
    ''
  );
  min-length = 4;
in
{
  options = {
    pinenote-waybar.enable = lib.mkEnableOption "enables pinenote waybar config";
  };
  config = lib.mkIf config.pinenote-waybar.enable {
    # systemd.user.services.waybar = {
    #   Service.Environment = "PATH=/etc/profiles/per-user/${config.home.username}/bin/:/run/current-system/sw/bin/";
    # };
    stylix.targets.waybar.enable = false;
    programs.waybar = {
      enable = true;
      # systemd.enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 40;

          "modules-left" = [
            "custom/smenu"
            "custom/oskb"
            "custom/mvws_prev"
            "custom/mvws_next"
            "custom/gows_prev"
            "custom/gows_next"
            # "custom/windown"
            # "custom/winright"
            # "custom/splitv"
            # "custom/splith"
          ];
          "modules-center" = [
            "sway/mode"
          ];
          "modules-right" = [
            "custom/ebc_cycle_driver_mode"
            "custom/ebc_refresh"
            "custom/blc_down"
            # "backlight/slider#cool"
            "custom/blc_up"
            "custom/blw_down"
            # "backlight/slider#warm"
            "custom/blw_up"
            # "idle_inhibitor"
            "battery"
            "tray"
            # "clock#time"
            "custom/kill"
          ];

          "backlight/slider#cool" = {
            device = "backlight_cool";
          };
          "backlight/slider#warm" = {
            device = "backlight_warm";
          };
          "battery" = {
            bat = "rk817-battery";
            name = "battery";
            interval = 10;
            states = {
              warning = 30;
              critical = 15;
            };
            "format" = " {icon} {capacity}%";
            "format-discharging" = "{capacity}% {icon} ";
            "format-icons" = [
              "" # Icon = battery-full
              "" # Icon = battery-three-quarters
              "" # Icon = battery-half
              "" # Icon = battery-quarter
              "" # Icon = battery-empty
            ];
            "min-length" = 5;
            "tooltip" = true;
          };

          "clock#time" = {
            "interval" = 1;
            "format" = "{:%H:%M}";
            "tooltip" = false;
          };

          "clock#date" = {
            "interval" = 10;
            "format" = "  {:%e %b %Y}";
            "tooltip-format" = "{:%e %B %Y}";
          };

          "cpu" = {
            "interval" = 5;
            "format" = "  {usage}%";
            "states" = {
              "warning" = 70;
              "critical" = 90;
            };
          };

          "memory" = {
            "interval" = 5;
            "format" = "  {}%";
            "states" = {
              "warning" = 70;
              "critical" = 90;
            };
          };

          "sway/mode" = {
            # ????
            "format" = "<span style=\"italic\">  {}</span>";
            "tooltip" = false;
          };

          "sway/window" = {
            "format" = "{}";
            "max-length" = 120;
          };

          # "temperature" = {
          #   "critical-threshold" = 80;
          #   "interval" = 5;
          #   "format" = "{icon}  {temperatureC}°C";
          #   "format-icons" = [
          #     "" # Icon = temperature-empty
          #     "" # Icon = temperature-quarter
          #     "" # Icon = temperature-half
          #     "" # Icon = temperature-three-quarters
          #     "" # Icon = temperature-full
          #   ];
          #   "tooltip" = true;
          #   "hwmon-path" = "/sys/class/hwmon/hwmon3/temp1_input";
          # };

          "custom/kill" = {
            "format" = "";
            "interval" = "once";
            "on-click" = "swaymsg kill";
            inherit min-length;
            "tooltip" = false;
          };
          "custom/winleft" = {
            "format" = "";
            "interval" = "once";
            "on-click" = "swaymsg move left";
            inherit min-length;
            "tooltip" = false;
          };
          "custom/winright" = {
            "format" = "";
            "interval" = "once";
            "on-click" = "swaymsg move right";
            inherit min-length;
            "tooltip" = false;
          };
          "custom/winup" = {
            "format" = "";
            "interval" = "once";
            "on-click" = "swaymsg move up";
            inherit min-length;
            "tooltip" = false;
          };
          "custom/windown" = {
            "format" = "";
            "interval" = "once";
            "on-click" = "swaymsg move down";
            inherit min-length;
            "tooltip" = false;
          };
          "custom/splitv" = {
            "format" = "/|";
            "interval" = "once";
            "on-click" = "swaymsg splitv";
            inherit min-length;
            "tooltip" = false;
          };
          "custom/splith" = {
            "format" = "/-";
            "interval" = "once";
            "on-click" = "swaymsg splith";
            inherit min-length;
            "tooltip" = false;
          };
          "custom/mvws_prev" = {
            "format" = "";
            "interval" = "once";
            "on-click" = "${sway-workspace} move prev";
            inherit min-length;
            "tooltip" = false;
          };
          "custom/gows_prev" = {
            "format" = "&lt;"; # "<" wont work, markup error
            "interval" = "once";
            "on-click" = "${sway-workspace} goto prev";
            inherit min-length;
            "tooltip" = false;
          };
          "custom/gows_next" = {
            "format" = ">";
            "interval" = "once";
            "on-click" = "${sway-workspace} goto next";
            inherit min-length;
            "tooltip" = false;
          };
          "custom/mvws_next" = {
            "format" = "";
            "interval" = "once";
            "on-click" = "${sway-workspace} move next";
            inherit min-length;
            "tooltip" = false;
          };
          "custom/oskb" = {
            "format" = "";
            "interval" = "once";
            "on-click" = toggle-onscreen-keyboard;
            inherit min-length;
            "tooltip" = false;
          };

          "custom/smenu" = {
            "format" = "";
            "interval" = "once";
            "on-click" = "${pkgs.nwg-launchers}/bin/nwggrid"; # TODO:
            inherit min-length;
            "tooltip" = false;
          };

          "custom/ws1" = {
            "format" = "1";
            "interval" = "once";
            "on-click" = "swaymsg workspace number 1";
            inherit min-length;
            "tooltip" = false;
          };
          "custom/ws2" = {
            "format" = "2";
            "interval" = "once";
            "on-click" = "swaymsg workspace number 2";
            inherit min-length;
            "tooltip" = false;
          };
          "custom/ws3" = {
            "format" = "3";
            "interval" = "once";
            "on-click" = "swaymsg workspace number 3";
            inherit min-length;
            "tooltip" = false;
          };
          "custom/ws4" = {
            "format" = "4";
            "interval" = "once";
            "on-click" = "swaymsg workspace number 4";
            inherit min-length;
            "tooltip" = false;
          };
          "custom/ws5" = {
            "format" = "5";
            "interval" = "once";
            "on-click" = "swaymsg workspace number 5";
            inherit min-length;
            "tooltip" = false;
          };

          "custom/blc_down" = {
            "format" = "";
            "interval" = "once";
            "on-click" = "${lib.getExe pkgs.brightnessctl} --device=backlight_cool set 10%-";
            inherit min-length;
            "tooltip" = false;
          };
          "custom/blc_up" = {
            "format" = "";
            "interval" = "once";
            "on-click" = "${lib.getExe pkgs.brightnessctl} --device=backlight_cool set 10%+";
            inherit min-length;
            "tooltip" = false;
          };
          "custom/blw_down" = {
            "format" = "";
            "interval" = "once";
            "on-click" = "${lib.getExe pkgs.brightnessctl} --device=backlight_warm set 10%-";
            inherit min-length;
            "tooltip" = false;
          };
          "custom/blw_up" = {
            "format" = "";
            "interval" = "once";
            "on-click" = "${lib.getExe pkgs.brightnessctl} --device=backlight_warm set 10%+";
            inherit min-length;
            "tooltip" = false;
          };
          "idle_inhibitor" = {
            "format" = "{icon}";
            "format-icons" = {
              "activated" = "";
              "deactivated" = "";
            };
            inherit min-length;
          };
          "custom/ebc_cycle_driver_mode" = {
            "format" = "🚲";
            "interval" = "once";
            "on-click" = cycle-driver-mode;
            inherit min-length;
            "tooltip" = false;
          };
          "custom/ebc_refresh" = {
            "format" = "";
            "interval" = "once";
            "on-click" =
              "${lib.getExe' pkgs.dbus "dbus-send"} --type=method_call --dest=org.pinenote.ebc_custom / org.pinenote.ebc_custom.GlobalRefresh";
            inherit min-length;
            "tooltip" = false;
          };
          "custom/rotate_0" = {
            "format" = "R0";
            "interval" = "once";
            "on-click" = "sway_rotate.sh rotnormal"; # TODO:
            inherit min-length;
            "tooltip" = false;
          };

          "custom/rotate_90" = {
            "format" = "R90";
            "interval" = "once";
            "on-click" = "sway_rotate.sh rotright";
            inherit min-length;
            "tooltip" = false;
          };

          "custom/rotate_180" = {
            "format" = "R180";
            "interval" = "once";
            "on-click" = "sway_rotate.sh rotinvert";
            inherit min-length;
            "tooltip" = false;
          };

          "custom/rotate_270" = {
            "format" = "R270";
            "interval" = "once";
            "on-click" = "sway_rotate.sh rotleft";
            inherit min-length;
            "tooltip" = false;
          };

          "custom/key_pageup" = {
            "format" = "";
            "interval" = "once";
            # "on-click" = "wtype -P page_up";
            "on-click" = "swaymsg resize grow width 10px; swaymsg resize grow height 10px";
            inherit min-length;
            "tooltip" = false;
          };
          "custom/key_pagedown" = {
            "format" = "";
            "interval" = "once";
            # "on-click" = "wtype -P page_down";
            "on-click" = "swaymsg resize shrink width 10px; swaymsg resize shrink height 10px";
            inherit min-length;
            "tooltip" = false;
          };

          "custom/battery_watts" = {
            "exec" = "battery_watts.sh"; # TODO:
            "format" = " {}W";
            "interval" = 10;
            inherit min-length;
            "tooltip" = false;
          };
          "tray" = {
            "icon-size" = 21;
            "spacing" = 10;
          };
        };
      };
      style = ''
        #workspaces {
        	padding: 0 0px;
        	margin: 0 0px;
        }

        window#waybar {
        	background: black;
        	color: white;
        }

        #custom-smenu,
        #custom-okb,
        #custom-windown,
        #custom-winright,
        #custom-splitv,
        #custom-splith,
        #custom-mvws_prev,
        #custom-gows_prev,
        #custom-gows_next,
        #custom-mvws_next,
        #sway-mode,
        #custom-ebc_refresh,
        #custom-blc_down,
        #custom-blc_up,
        #custom-blw_down,
        #custom-blw_up,
        #backlight-slider,
        #idle_inhibitor,
        #battery,
        #custom-kill {
        	color: #ffffff;
        }

        #backlight-slider slider {
            min-height: 0px;
            min-width: 0px;
            opacity: 0;
            background-size: 20px;
            border: none;
            box-shadow: none;
        }

        #backlight-slider.cool slider {
        }

        #backlight-slider.warm slider {
        }

        #backlight-slider trough {
           min-height: 10px;
           min-width: 120px;
           border-radius: 5px;
           background-color: dimgrey;
        }

        #backlight-slider highlight {
           min-width: 10px;
           border-radius: 5px;
           background-color: white;
        }
      '';
    };
  };
}
