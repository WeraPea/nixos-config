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
  min-length = 4;
in
{
  options = {
    fajita.waybar.enable = lib.mkEnableOption "enables fajita waybar config";
  };
  config = lib.mkIf config.fajita.waybar.enable {
    stylix.targets.waybar.enable = false;
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 40;

          modules-left = [
            "custom/menu"
            "custom/oskb"
          ];
          modules-right = [
            "custom/bl_down"
            "custom/bl_up"
            # "idle_inhibitor"
            "battery"
            "tray"
            # "clock#time"
            "custom/kill"
          ];

          # battery = {
          #   bat = ""; # TODO
          #   name = "battery";
          #   interval = 10;
          #   states = {
          #     warning = 30;
          #     critical = 15;
          #   };
          #   format = " {icon} {capacity}%";
          #   format-discharging = "{capacity}% {icon} ";
          #   format-icons = [
          #     "" # Icon = battery-full
          #     "" # Icon = battery-three-quarters
          #     "" # Icon = battery-half
          #     "" # Icon = battery-quarter
          #     "" # Icon = battery-empty
          #   ];
          #   min-length = 5;
          #   tooltip = true;
          # };
          "custom/kill" = {
            format = "";
            interval = "once";
            on-click = "hyprctl dispatch killactive";
            inherit min-length;
            tooltip = false;
          };
          "custom/oskb" = {
            format = "";
            interval = "once";
            on-click = toggle-onscreen-keyboard;
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

          "custom/bl_down" = {
            format = "";
            interval = "once";
            on-click = "${lib.getExe pkgs.brightnessctl} set 10%-";
            inherit min-length;
            tooltip = false;
          };
          "custom/bl_up" = {
            format = "";
            interval = "once";
            on-click = "${lib.getExe pkgs.brightnessctl} set 10%+";
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
          tray = {
            icon-size = 21;
            spacing = 10;
          };
        };
      };
      style = # css
        ''
          #workspaces {
          	padding: 0 0px;
          	margin: 0 0px;
          }

          window#waybar {
          	background: black;
          	color: #d0d0d0;
          }

          window#waybar {
              font-size: 30px;
          }

          #custom-menu,
          #custom-okb,
          #custom-windown,
          #custom-winright,
          #custom-splitv,
          #custom-splith,
          #custom-mvws_prev,
          #custom-gows_prev,
          #custom-gows_next,
          #custom-mvws_next,
          #idle_inhibitor,
          #battery,
          #custom-kill {
          	/* color: #ffffff; */
          }
        '';
    };
  };
}
