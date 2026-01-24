{ config, ... }:
{
  imports = [
    ./boot.nix
    ./vaultwarden.nix
    ./caddy.nix
    ./linkwarden.nix
  ];
  user.hostname = "server";
  networking.domain = "werapi.duckdns.org";
  graphics.enable = false;
  system.stateVersion = "24.11";
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
