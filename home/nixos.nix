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
        waybar.enable = true;
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
              monitorrule=DP-2,0.5,1,tile,0,1,${toString DP_2_x},${toString DP_2_y},${toString DP_2_width},${toString DP_2_height},144,0,0,0,0
              monitorrule=HDMI-A-1,0.5,1,tile,0,1,${toString HDMI_A_1_x},${toString HDMI_A_1_y},${toString HDMI_A_1_width},${toString HDMI_A_1_height},75,0,0,0,0
              monitorrule=HDMI-A-2,0.5,1,tile,0,1,${toString HDMI_A_2_x},${toString HDMI_A_2_y},${toString HDMI_A_2_width},${toString HDMI_A_2_height},60,${toString HDMI_A_2_overscan_top},${toString HDMI_A_2_overscan_bottom},${toString HDMI_A_2_overscan_left},${toString HDMI_A_2_overscan_right}

              bind=SUPER,F1,focusmon,HDMI-A-1
              bind=SUPER,F1,comboview,1
              bind=SUPER,F2,focusmon,HDMI-A-1
              bind=SUPER,F2,comboview,2
              bind=SUPER,F3,focusmon,HDMI-A-1
              bind=SUPER,F3,comboview,3
              bind=SUPER,F4,focusmon,HDMI-A-2
              bind=SUPER,F4,comboview,1
              bind=SUPER,F5,focusmon,HDMI-A-2
              bind=SUPER,F5,comboview,2

              bind=SUPER+SHIFT,F1,tagmon,HDMI-A-1
              bind=SUPER+SHIFT,F1,tag,1
              bind=SUPER+SHIFT,F2,tagmon,HDMI-A-1
              bind=SUPER+SHIFT,F2,tag,2
              bind=SUPER+SHIFT,F3,tagmon,HDMI-A-1
              bind=SUPER+SHIFT,F3,tag,3
              bind=SUPER+SHIFT,F4,tagmon,HDMI-A-2
              bind=SUPER+SHIFT,F4,tag,1
              bind=SUPER+SHIFT,F5,tagmon,HDMI-A-2
              bind=SUPER+SHIFT,F5,tag,2
            '';
          mainDisplay = "DP-2";
        };
      }
    ];
    users.wera = import ./home.nix;
  };
}
