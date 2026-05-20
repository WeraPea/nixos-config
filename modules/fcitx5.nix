{
  config,
  lib,
  pkgs,
  ...
}:
let
  moduleName = "fcitx5";
  cfg = config.werapi.${moduleName};
in
{
  options.werapi.${moduleName} = {
    enable = lib.mkOption {
      default = config.werapi.graphics.enable;
      description = "Whether to enable ${moduleName}.";
      type = lib.types.bool;
    };
  };
  config = lib.mkIf cfg.enable {
    hm.i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        addons = with pkgs; [
          fcitx5-gtk
          fcitx5-mozc-ut
        ];
        waylandFrontend = true;
        settings.inputMethod = {
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "keyboard-us";
          };
          "Groups/0/Items/0" = {
            "Name" = "keyboard-us";
          };
          "Groups/0/Items/1" = {
            "Name" = "mozc";
          };
        };
      };
    };
  };
}
