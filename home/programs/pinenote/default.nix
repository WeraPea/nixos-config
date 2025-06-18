{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./sway.nix
    ./hyprland.nix
    ./waybar.nix
    ./switch-boot-partition.nix
  ];
  options = {
    pinenote.enable = lib.mkEnableOption "enables pinenote config";
  };
  config = lib.mkIf config.pinenote.enable {
    pinenote-sway.enable = false;
    pinenote-waybar.enable = true;
    pinenote-hyprland.enable = true;
    xdg.configFile."nwg-launchers/nwggrid/grid.conf".text = ''
      {
        "categories": { },
        "favorites" : false,
        "pins" : false,
        "columns" : 6,
        "icon-size" : 72,
        "no-categories": true,
        "oneshot" : false
      }
    '';
    xdg.configFile."nwg-launchers/nwggrid/style.css".text = ''
      scrolledwindow, button, label, box {
        background: #ffffff;
        color: #000000;
      }
    ''; # TODO: find alternative to nwggrid
    home.packages = [
      (pkgs.callPackage ./rotate.nix { })
    ];
  };
}
