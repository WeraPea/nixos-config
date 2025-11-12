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
      activeConfig = "default";
      configs.default = ./shell;
      systemd.enable = true;
      package = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };
  };
}
