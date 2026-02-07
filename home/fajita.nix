{
  lib,
  pkgs,
  ...
}:
{
  home-manager = {
    sharedModules = [
      {
        home.username = "wera";
        home.homeDirectory = "/home/wera";
        home.stateVersion = "25.11";
        home.packages = with pkgs; [
          # chatty
          brightnessctl
        ];
        programs.zathura.enable = false;
        desktopPackages.enable = false;

        koreader.enable = true;
        services.swww.enable = lib.mkForce false;
        wvkbd.enable = true;

        mango = {
          enable = true;
          mainDisplay = "DSI-1";
          extraConfig = # hyprlang
            ''
              monitorrule=name:DSI-1,scale:1.5,x:0,y:0,width:1080,height:2340,refresh:60
              bind=NONE,XF86PowerOff,spawn,${lib.getExe pkgs.wlopm} --toggle "*"
            '';
        };
        quickshell.enable = true;
        programs.quickshell.activeConfig = "fajita";

        firefox = {
          mobile.enable = true;
          minimal.enable = true;
        };

        mpv.enable = false;
      }
    ];
    users.wera = import ./home.nix;
  };
}
