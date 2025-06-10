{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
{
  options = {
    fcitx5.enable = lib.mkEnableOption "enables fcitx5";
  };
  config = lib.mkIf config.fcitx5.enable {
    i18n.inputMethod = lib.mkIf osConfig.graphics.enable {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-gtk
        fcitx5-mozc
      ];
    };
  };
}
