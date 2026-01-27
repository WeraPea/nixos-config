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
          packages = with pkgs; [ brightnessctl ];
          stateVersion = "23.11";
        };
        mango = {
          enable = true;
          extraConfig = # hyprlang
            ''
              monitorrule=name:eDP-1,x:0,y:0,width:1920,height:1080,refresh:60
            '';
          mainDisplay = "eDP-1";
        };
        quickshell.enable = true;
      }
    ];
    users.wera = import ./home.nix;
  };
}
