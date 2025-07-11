{ pkgs, config, ... }:
{
  networking.firewall.allowedTCPPorts = [ 80 ];
  sops.secrets.nextcloud_root_pass = {
    owner = "nextcloud";
  };
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud31;
    hostName = "server";
    https = false;
    config = {
      adminpassFile = config.sops.secrets.nextcloud_root_pass.path;
      dbtype = "pgsql";
      dbname = "nextcloud";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql";
    };
    extraApps = with config.services.nextcloud.package.packages.apps; {
      inherit bookmarks memories recognize;
    };
    extraAppsEnable = true;
  };
}
