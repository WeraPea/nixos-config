{ lib, config, ... }:
{
  imports = [
    ./sway.nix
    ./waybar.nix
    ./switch-boot-partition.nix
  ];
  options = {
    pinenote.enable = lib.mkEnableOption "enables pinenote config";
  };
  config = lib.mkIf config.pinenote.enable {
    pinenote-sway.enable = true;
    pinenote-waybar.enable = true;
  };
}
