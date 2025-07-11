{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  options = {
    quickshell.enable = lib.mkEnableOption "Enables quickshell";
  };
  config = lib.mkIf config.quickshell.enable {
    programs.quickshell = {
      enable = true;
      package = inputs.quickshell.packages.${pkgs.system}.default;
    };
    xdg.configFile."quickshell/default" = {
      source = ./shell;
      recursive = true;
    };
  };
}
