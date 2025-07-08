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
          megapixels
          chatty
        ];
        i18n.inputMethod.fcitx5 = {
          addons = [
            inputs.fcitx-virtualkeyboard-adapter.packages.${pkgs.system}.virtualkeyboard-adapter
          ];
          settings.addons = {
            virtualkeyboardadapter.globalSection.ActivateCmd = ''"pkill -SIGUSR2 wvkbd"'';
            virtualkeyboardadapter.globalSection.DeactivateCmd = ''"pkill -SIGUSR1 wvkbd"'';
          };
        };
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
