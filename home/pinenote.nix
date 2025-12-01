{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
{
  home-manager = {
    sharedModules = [
      {
        stylix.targets.fish.enable = false;
        home.username = "wera";
        home.homeDirectory = "/home/wera";
        home.stateVersion = "25.05";
        home.packages = with pkgs; [
          brightnessctl
          xournalpp
        ];
        mpv.enable = false;
        spicetify.enable = false;
        programs.zathura.enable = false;
        desktopPackages.enable = false;
        pinenote.enable = true; # TODO: remove this, along with the fajita.enable
        koreader.enable = true;
        services.hyprpaper.enable = lib.mkForce false;
        wvkbd.enable = true;

        mango = {
          enable = true;
          mainDisplay = "DPI-1";
          extraConfig = # hyprlang
            ''
              monitorrule=DPI-1,0.5,1,tile,0,1.5,0,0,1872,1404,84.996002,0,0,0,0
            '';
        };
        # quickshell.enable = true;
      }
    ];
    users.wera = import ./home.nix;
  };
}
