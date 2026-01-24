{ pkgs, config, ... }:
{
  sops.secrets."duckdns/token" = { };
  sops.templates."caddy.env" = {
    content = ''
      DUCKDNS_TOKEN=${config.sops.placeholder."duckdns/token"}
    '';
    owner = "caddy";
  };
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/duckdns@v0.5.0" ];
      hash = "sha256-xVjw7QfnjdWIYGTfc4Ca91l8NeeEb/YKE8tMs4ctzTA=";
    };
    environmentFile = config.sops.templates."caddy.env".path;
    globalConfig = ''
      acme_dns duckdns {env.DUCKDNS_TOKEN}
    '';
  };
}
