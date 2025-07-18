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
          squeekboard
          xournalpp
        ];
        mpv.enable = false;
        spicetify.enable = false;
        programs.zathura.enable = false;
        desktopPackages.enable = false;
        pinenote.enable = true;
        koreader.enable = true;
      }
    ];
    users.wera = import ./home.nix;
  };
}
