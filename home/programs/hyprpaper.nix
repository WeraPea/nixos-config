{ config, lib, ... }:
lib.mkIf config.hyprland.enable {
  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      preload = [ "${config.stylix.image}" ];
      wallpaper = [
        "DP-2,${config.stylix.image}"
        "HDMI-A-1,${config.stylix.image}"
      ];
    };
  };
}
