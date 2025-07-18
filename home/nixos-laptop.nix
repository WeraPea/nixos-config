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
          packages = with pkgs; [ brightnessctl ];
          stateVersion = "23.11";
        };
        wayland.windowManager.hyprland.settings = {
          monitor = [
            "eDP-1,1920x1080@60,0x0,1"
          ];
          workspace = [
            "1,persistent:true,monitor:eDP-1"
            "2,persistent:true,monitor:eDP-1"
            "3,persistent:true,monitor:eDP-1"
            "4,persistent:true,monitor:eDP-1"
            "5,persistent:true,monitor:eDP-1"
          ];
          device = {
            name = "alpsps/2-alps-dualpoint-touchpad";
            middle_button_emulation = 1;
          };
        };
      }
    ];
    users.wera = import ./home.nix;
  };
}
