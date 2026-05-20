{
  config,
  lib,
  ...
}:
let
  moduleName = "vaultwarden";
  cfg = config.werapi.${moduleName};
  domain = "vault.${config.werapi.domain}";
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
    sops.secrets."vaultwarden/admin_token" = { };

    sops.templates."vaultwarden.env" = {
      content = ''
        ADMIN_TOKEN=${config.sops.placeholder."vaultwarden/admin_token"}
      '';
      owner = "vaultwarden";
    };
    services.vaultwarden = {
      enable = true;
      backupDir = "/var/backup/vaultwarden";
      environmentFile = config.sops.templates."vaultwarden.env".path;
      config = {
        DOMAIN = "https://${domain}";
        SIGNUPS_ALLOWED = false;

        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
        ROCKET_LOG = "critical";
      };
    };
    services.caddy.virtualHosts."${domain}".extraConfig = ''
      encode zstd gzip

      reverse_proxy :${toString config.services.vaultwarden.config.ROCKET_PORT} {
          header_up X-Real-IP {remote_host}
      }
    '';
  };
}
