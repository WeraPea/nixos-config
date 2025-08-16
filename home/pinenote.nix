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
        pinenote.enable = true; # TODO: remove this, along with the fajita.enable
        koreader.enable = true;
        hyprland.enable = true;
        hyprland.touch.enable = true;
        stylix.targets.hyprpaper.enable = lib.mkForce false;
        services.hyprpaper.enable = lib.mkForce false;
        wayland.windowManager.hyprland.settings = {
          monitor = [
            "DPI-1,highrr,0x0,1"
          ];
          windowrule = [
            "tag +ebchint:Y4|r:, class:KOReader" # trailing : as hyprland appends "*" to dynamic tags TODO: change this perhaps?
          ];
          workspace = [
            "1,persistent:true,monitor:DPI-1"
            "2,persistent:true,monitor:DPI-1"
            "3,persistent:true,monitor:DPI-1"
          ];
          animations.enabled = lib.mkForce false;
          animations.animation = [
            "workspaces,0,1,default,slide" # determinates the slide direction of the gestures
          ];
          gestures = {
            workspace_swipe_cancel_ratio = 0.05;
          };
          plugin.touch_gestures = { # TODO: find a way to disable animations for this
            sensitivity = lib.mkForce 8.0;
            edge_margin = lib.mkForce 80;
          };
          exec-once = [ "waybar" ];
        };
        wvkbd.enable = true; # TODO: fix keyboard appearing in koreader (wrapper script that checks focussed window and applies a blacklist)
      }
    ];
    users.wera = import ./home.nix;
  };
}
