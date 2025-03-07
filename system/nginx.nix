{ config, ... }:
{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts = {
      "www.werapi.duckdns.org" = {
        locations."/" = {
          return = "301 https://nextcloud.werapi.duckdns.org";
        };
        useACMEHost = "werapi.duckdns.org";
        acmeRoot = null;
        forceSSL = true;
      };
      ${config.services.nextcloud.hostName} = {
        useACMEHost = "werapi.duckdns.org";
        acmeRoot = null;
        forceSSL = true;
      };
    };
  };
  users.users.nginx.extraGroups = [ "acme" ];
  security.acme = {
    acceptTerms = true;
    defaults.email = "sokneip@tuta.io";
    certs."werapi.duckdns.org" = {
      dnsProvider = "duckdns";
      credentialFiles."DUCKDNS_TOKEN_FILE" = config.sops.secrets.duckdns_token.path;
      domain = "*.werapi.duckdns.org";
    };
  };
}
