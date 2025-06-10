{
  lib,
  pkgs,
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
        services.kdeconnect.enable = lib.mkForce false;
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
