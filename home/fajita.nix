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
          chatty
        ];
        mpv.enable = false;
        spicetify.enable = false;
        programs.zathura.enable = false;
        desktopPackages.enable = false;
        fajita.enable = true;
        quickshell.enable = true;
        programs.quickshell.systemd.enable = lib.mkForce false; # for testing mobile configuration
        hyprland.enable = true;
        hyprland.touch.enable = true;
        stylix.targets.hyprpaper.enable = lib.mkForce false;
        services.hyprpaper.enable = lib.mkForce false;
        wayland.windowManager.hyprland.settings = {
          monitor = [
            "DSI-1,1080x2340@60,0x0,1.5"
          ];
          animations.animation = [
            "workspaces,1,8,default,slide" # determinates the slide direction of the gestures
          ];
          gestures = {
            workspace_swipe_cancel_ratio = 0.25;
          };
          exec-once = [ "waybar" ];
        };
        wvkbd.enable = true;

        # koreader.enable = true;
      }
    ];
    users.wera = import ./home.nix;
  };
}
