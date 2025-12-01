# based on waybar config by hrdl
{
  lib,
  pkgs,
  config,
  inputs,
  outputs,
  ...
}:
let
  cycle-driver-mode = lib.getExe (
    pkgs.writers.writePython3Bin "cycle_driver_mode" {
      libraries = [
        inputs.pinenote-nixos-follows.packages.${pkgs.stdenv.hostPlatform.system}.rockchip-ebc-custom-ioctl
      ];
      doCheck = false;
    } "import rockchip_ebc_custom_ioctl as reci; reci.cycle_driver_mode()" # TODO: move to using pinenote-service
  );
  min-length = 4;
in
{
  options = {
    pinenote-waybar.enable = lib.mkEnableOption "enables pinenote waybar config";
  };
  config = lib.mkIf config.pinenote-waybar.enable {
    stylix.targets.waybar.enable = false;
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 30;

          modules-left = [
            "custom/menu"
            "custom/mvws_prev"
            "custom/mvws_next"
            "custom/gows_prev"
            "custom/gows_next"
          ];
          modules-right = [
            "custom/rotate"
            "custom/ebc_refresh"
            "custom/usb_tablet"
            "custom/ebc_cycle_driver_mode"
            "custom/blc_down"
            "custom/blc_up"
            "custom/blw_down"
            "custom/blw_up"
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
          battery = {
            bat = "rk817-battery";
            name = "battery";
            interval = 10;
            states = {
              warning = 30;
              critical = 15;
            };
            format = " {icon} {capacity}%";
            format-discharging = "{capacity}% {icon} ";
            format-icons = [
              "" # Icon = battery-full
              "" # Icon = battery-three-quarters
              "" # Icon = battery-half
              "" # Icon = battery-quarter
              "" # Icon = battery-empty
            ];
            min-length = 5;
            tooltip = true;
          };
          "custom/kill" = {
            format = "";
            interval = "once";
            on-click = "mmsg -d killclient";
            inherit min-length;
            tooltip = false;
          };
          "custom/mvws_prev" = {
            format = "";
            interval = "once";
            on-click = "mmsg -d tagtoleft";
            inherit min-length;
            tooltip = false;
          };
          "custom/gows_prev" = {
            format = "&lt;"; # "<" wont work, markup error
            interval = "once";
            on-click = "mmsg -d viewtoleft";
            inherit min-length;
            tooltip = false;
          };
          "custom/gows_next" = {
            format = ">";
            interval = "once";
            on-click = "mmsg -d viewtoright";
            inherit min-length;
            tooltip = false;
          };
          "custom/mvws_next" = {
            format = "";
            interval = "once";
            on-click = "mmsg -d tagtoright";
            inherit min-length;
            tooltip = false;
          };

          "custom/menu" = {
            format = "";
            interval = "once";
            on-click = "${pkgs.nwg-launchers}/bin/nwggrid"; # TODO:
            inherit min-length;
            tooltip = false;
          };

          "custom/blc_down" = {
            format = "";
            interval = "once";
            on-click = "${lib.getExe pkgs.brightnessctl} --device=backlight_cool set 10%-";
            inherit min-length;
            tooltip = false;
          };
          "custom/blc_up" = {
            format = "";
            interval = "once";
            on-click = "${lib.getExe pkgs.brightnessctl} --device=backlight_cool set 10%+";
            inherit min-length;
            tooltip = false;
          };
          "custom/blw_down" = {
            format = "";
            interval = "once";
            on-click = "${lib.getExe pkgs.brightnessctl} --device=backlight_warm set 10%-";
            inherit min-length;
            tooltip = false;
          };
          "custom/blw_up" = {
            format = "";
            interval = "once";
            on-click = "${lib.getExe pkgs.brightnessctl} --device=backlight_warm set 10%+";
            inherit min-length;
            tooltip = false;
          };
          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = "";
              deactivated = "";
            };
            inherit min-length;
          };
          "custom/ebc_cycle_driver_mode" = {
            format = "󰃐";
            interval = "once";
            on-click = cycle-driver-mode;
            inherit min-length;
            tooltip = false;
          };
          "custom/ebc_refresh" = {
            format = "";
            interval = "once";
            on-click = "${lib.getExe' pkgs.dbus "dbus-send"} --dest=org.pinenote.PineNoteCtl --type=method_call /org/pinenote/PineNoteCtl org.pinenote.Ebc1.GlobalRefresh";
            inherit min-length;
            tooltip = false;
          };
          tray = {
            icon-size = 21;
            spacing = 10;
          };
          "custom/usb_tablet" = {
            format = "󰓶";
            on-click = "setsid sudo ${
              lib.getExe outputs.packages.${pkgs.stdenv.hostPlatform.system}.usb-tablet
            }"; # added to sudoers file so no password required
            inherit min-length;
            tooltip = false;
          };
          "custom/rotate" = {
            format = "󰚪";
            on-click = "${lib.getExe (pkgs.callPackage ./rotate.nix { })} switch"; # TODO: add a Menu for more rotations
            inherit min-length;
            tooltip = false;
          };
        };
      };
      style = # css
        ''
          window#waybar {
          	background: black;
          	color: white;
            font-size: 20px;
          }
        '';
    };
  };
}
