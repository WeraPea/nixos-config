{
  config,
  lib,
  pkgs,
  ...
}:
let
  moduleName = "caddy";
  cfg = config.werapi.${moduleName};
in
{
  options.werapi.${moduleName} = {
    enable = lib.mkOption {
      default = false;
      description = "Whether to enable ${moduleName}.";
      type = lib.types.bool;
    };
  };
  config = lib.mkIf cfg.enable {
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
    services.caddy.virtualHosts."anki.${config.werapi.domain}".extraConfig = ''
      reverse_proxy nixos:8765
    ''; # TODO: move this?
  };
}
