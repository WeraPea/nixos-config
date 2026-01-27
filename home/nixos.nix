{
  inputs,
  pkgs,
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

              bind=SUPER,F1,focusmon,HDMI-A-1
              bind=SUPER,F1,view,1
              bind=SUPER,F2,focusmon,HDMI-A-1
              bind=SUPER,F2,view,2
              bind=SUPER,F3,focusmon,HDMI-A-1
              bind=SUPER,F3,view,3
              bind=SUPER,F4,focusmon,HDMI-A-1
              bind=SUPER,F4,view,4
              bind=SUPER,F5,focusmon,HDMI-A-1
              bind=SUPER,F5,view,5

              bind=SUPER,6,focusmon,HDMI-A-2
              bind=SUPER,6,view,1
              bind=SUPER,7,focusmon,HDMI-A-2
              bind=SUPER,7,view,2
              bind=SUPER,8,focusmon,HDMI-A-2
              bind=SUPER,8,view,3
              bind=SUPER,9,focusmon,HDMI-A-2
              bind=SUPER,9,view,4
              bind=SUPER,0,focusmon,HDMI-A-2
              bind=SUPER,0,view,5

              bind=SUPER+SHIFT,F1,tagmon,HDMI-A-1
              bind=SUPER+SHIFT,F1,tag,1
              bind=SUPER+SHIFT,F2,tagmon,HDMI-A-1
              bind=SUPER+SHIFT,F2,tag,2
              bind=SUPER+SHIFT,F3,tagmon,HDMI-A-1
              bind=SUPER+SHIFT,F3,tag,3
              bind=SUPER+SHIFT,F4,tagmon,HDMI-A-1
              bind=SUPER+SHIFT,F4,tag,4
              bind=SUPER+SHIFT,F5,tagmon,HDMI-A-1
              bind=SUPER+SHIFT,F5,tag,5

              bind=SUPER+SHIFT,6,tagmon,HDMI-A-2
              bind=SUPER+SHIFT,6,tag,1
              bind=SUPER+SHIFT,7,tagmon,HDMI-A-2
              bind=SUPER+SHIFT,7,tag,2
              bind=SUPER+SHIFT,8,tagmon,HDMI-A-2
              bind=SUPER+SHIFT,8,tag,3
              bind=SUPER+SHIFT,9,tagmon,HDMI-A-2
              bind=SUPER+SHIFT,9,tag,4
              bind=SUPER+SHIFT,0,tagmon,HDMI-A-2
              bind=SUPER+SHIFT,0,tag,5
            '';
          mainDisplay = "DP-2";
        };
        quickshell.enable = true;
        beets.enable = true;
      }
    ];
    users.wera = import ./home.nix;
  };
}
