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
          extraConfig = # hyprlang
            ''
              monitorrule=DP-2,0.5,1,tile,0,1,1824,0,2560,1440,144,0,0,0,0
              monitorrule=HDMI-A-1,0.5,1,tile,0,1,4384,0,1280,1024,75,0,0,0,0
              monitorrule=HDMI-A-2,0.5,1,tile,0,1,0,385,1920,1080,60,25,25,96,96

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
