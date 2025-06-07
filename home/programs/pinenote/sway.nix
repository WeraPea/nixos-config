# based on sway config by hrdl
{
  lib,
  pkgs,
  config,
  ...
}:
{
  options = {
    pinenote-sway.enable = lib.mkEnableOption "enables pinenote sway config";
  };
  config = lib.mkIf config.pinenote-sway.enable {
    stylix.targets.sway.enable = false;
    wayland.windowManager.sway = {
      enable = true;
      systemd.enable = true;
      wrapperFeatures.gtk = true;
      config = rec {
        terminal = "kitty";
        window = {
          border = 0;
          titlebar = false;
        };
        floating = window;
        output."*".bg = "#FFFFFF solid_color";
        output."*".scale = "2";
        input."0:0:cyttsp5".map_to_output = "DPI-1";
        input."11551:149:w9013_2D1F:0095_Stylus".map_to_output = "DPI-1";
        bars = [ { command = "${lib.getExe pkgs.waybar}"; } ];
        colors = {
          focused = {
            border = "#FFFFFF";
            background = "#000000";
            text = "#FFFFFF";
            indicator = "#FFFFFF";
            childBorder = "#FFFFFF";
          };
          focusedInactive = {
            border = "#000000";
            background = "#FFFFFF";
            text = "#000000";
            indicator = "#000000";
            childBorder = "#000000";
          };
          unfocused = {
            border = "#FFFFFF";
            background = "#FFFFFF";
            text = "#000000";
            indicator = "#FFFFFF";
            childBorder = "#FFFFFF";
          };
          urgent = {
            border = "#000000";
            background = "#FFFFFF";
            indicator = "#000000";
            childBorder = "#000000";
            text = "#000000";
          };
        };
      };
    };
  };
}
