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
        home.username = "wera";
        home.homeDirectory = "/home/wera";
        home.stateVersion = "25.11";
        home.packages = with pkgs; [
        ];
        mpv.enable = false;
        spicetify.enable = false;
        programs.zathura.enable = false;
        desktopPackages.enable = false;
        fajita.enable = true;
        # koreader.enable = true;
      }
    ];
    users.wera = import ./home.nix;
  };
}
