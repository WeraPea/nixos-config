{
  inputs,
  pkgs,
  lib,
  ...
}:
{

  home-manager = {
    sharedModules = [
      {
        home = {
          username = "wera";
          homeDirectory = "/home/wera";
          stateVersion = "23.11";
        };
        mango = {
          enable = true;
          extraConfig =
            with rec {
              DP_2_x = HDMI_A_2_x + HDMI_A_2_width - HDMI_A_2_overscan_right + 1;
              DP_2_y = 0;
              DP_2_width = 2560;
              DP_2_height = 1440;

              HDMI_A_1_x = DP_2_x + DP_2_width;
              HDMI_A_1_y = DP_2_y;
              HDMI_A_1_width = 1280;
              HDMI_A_1_height = 1024;

              HDMI_A_2_x = 0;
              HDMI_A_2_y = DP_2_y + DP_2_height - HDMI_A_2_height + HDMI_A_2_overscan_top;
              HDMI_A_2_width = 1920;
              HDMI_A_2_height = 1080;
              HDMI_A_2_overscan_top = 25;
              HDMI_A_2_overscan_bottom = 25;
              HDMI_A_2_overscan_left = 97;
              HDMI_A_2_overscan_right = 97;
            }; # hyprlang
            ''
              monitorrule=name:DP-2,x:${toString DP_2_x},y:${toString DP_2_y},width:${toString DP_2_width},height:${toString DP_2_height},refresh:144
              monitorrule=name:HDMI-A-1,x:${toString HDMI_A_1_x},y:${toString HDMI_A_1_y},width:${toString HDMI_A_1_width},height:${toString HDMI_A_1_height},refresh:75
              monitorrule=name:HDMI-A-2,x:${toString HDMI_A_2_x},y:${toString HDMI_A_2_y},width:${toString HDMI_A_2_width},height:${toString HDMI_A_2_height},refresh:60,overscan_top:${toString HDMI_A_2_overscan_top},overscan_bottom:${toString HDMI_A_2_overscan_bottom},overscan_left:${toString HDMI_A_2_overscan_left},overscan_right:${toString HDMI_A_2_overscan_right}
            '';
          mainDisplay = "DP-2";
          bindModes.default.binds.bind =
            (builtins.listToAttrs (
              builtins.concatMap (w: [
                (lib.nameValuePair "SUPER,F${w}" [
                  "focusmon,HDMI-A-1"
                  "view,${w}"
                ])
                (lib.nameValuePair "SUPER+SHIFT,F${w}" [
                  "tagmon,HDMI-A-1"
                  "tag,${w}"
                ])
              ]) (map toString (lib.range 1 5))
            ))
            // (builtins.listToAttrs (
              builtins.concatMap (w: [
                (lib.nameValuePair "SUPER,${toString (lib.mod (w + 5) 10)}" [
                  "focusmon,HDMI-A-2"
                  "view,${toString w}"
                ])
                (lib.nameValuePair "SUPER+SHIFT,F${toString (lib.mod (w + 5) 10)}" [
                  "tagmon,HDMI-A-2"
                  "tag,${toString w}"
                ])
              ]) (lib.range 1 5)
            ));

        };
        quickshell.enable = true;
        beets.enable = true;
      }
    ];
    users.wera = import ./home.nix;
  };
}
