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
            '';
          mainDisplay = "DP-2";
        };
      }
    ];
    users.wera = import ./home.nix;
  };
}
