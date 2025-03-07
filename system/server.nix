{ config, ... }:
{
  imports = [
    ./nextcloud.nix
    ./postgresql.nix
    ./nginx.nix
  ];
  user.hostname = "server";
  sql.enable = true;
  graphics.enable = false;
  system.stateVersion = "24.11";
  sops.secrets.duckdns_token = { };
  services.duckdns = {
    enable = true;
    domains = [ "werapi" ];
    tokenFile = config.sops.secrets.duckdns_token.path;
  };
  # ps2 samba server
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        # setting mostly from https://github.com/toolboc/psx-pi-smbshare
        "server min protocol" = "NT1";
        "server signing" = "disabled";
        "smb encrypt" = "disabled";
        "map to guest" = "bad user";
        "usershare allow guests" = "yes";
        "keepalive" = 0;
        "strict sync" = "no";
      };
      ps2 = {
        comment = "PS2 SMB";
        path = "/ps2samba";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        public = "yes";
        available = "yes";
        "force user" = "wera";
      };
    };
  };
}
