{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    sql.enable = lib.mkEnableOption "Enable mysql";
  };
  config = lib.mkIf config.sql.enable {
    services.mysql = {
      enable = true;
      package = pkgs.mariadb;
    };
  };
}
