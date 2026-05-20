{
  config,
  lib,
  ...
}:
let
  moduleName = "linkwarden";
  cfg = config.werapi.${moduleName};
  domain = "link.${config.werapi.domain}";
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
    services.linkwarden = {
      enable = true;
      host = "127.0.0.1";
      port = 3000;
      environmentFile = config.sops.templates."linkwarden.env".path;
    };
    sops = {
      secrets."linkwarden/nextauth_secret" = { };
      templates."linkwarden.env" = {
        owner = "linkwarden";
        content = ''
          NEXTAUTH_SECRET=${config.sops.placeholder."linkwarden/nextauth_secret"}
        '';
      };
    };
    services.caddy.virtualHosts."${domain}".extraConfig = ''
      reverse_proxy :${toString config.services.linkwarden.port}
    '';
  };
}
