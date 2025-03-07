{ pkgs, config, ... }:
{
  sops.secrets.nextcloud_root_pass = {
    owner = "nextcloud";
  };
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud30;
    hostName = "nextcloud.werapi.duckdns.org";
    https = true;
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
