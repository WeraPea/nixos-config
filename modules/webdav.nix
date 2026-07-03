let
  moduleName = "webdav";
in
{
  flake.modules.${moduleName}.nixos =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.werapi.${moduleName};
      domain = "webdav.${config.werapi.domain}";
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

        services.webdav = {
          enable = true;
          environmentFile = config.sops.templates."webdav.env".path;
          settings = {
            address = "127.0.0.1";
            port = 8060;
            directory = "/srv/webdav";
            permissions = "CRUD";
            cors = {
              enabled = true;
              credentials = true;
              allowed_hosts = [ "https://reader.mokuro.app" ];
              allowed_methods = [
                "GET"
                "PUT"
                "DELETE"
                "OPTIONS"
                "PROPFIND"
                "MKCOL"
              ];
              allowed_headers = [
                "Authorization"
                "Content-Type"
                "Depth"
                "Overwrite"
                "Destination"
              ];
            };
            users = [
              {
                username = "{env}USERNAME";
                password = "{env}PASSWORD";
              }
            ];

          };
        };
        networking.firewall.allowedTCPPorts = [ config.services.webdav.settings.port ];

        services.caddy.virtualHosts.${domain}.extraConfig = ''
          reverse_proxy :${toString config.services.webdav.settings.port}
        '';

        sops = {
          secrets."webdav/username" = { };
          secrets."webdav/password" = { };
          templates."webdav.env" = {
            owner = config.services.webdav.user;
            content = ''
              USERNAME=${config.sops.placeholder."webdav/username"}
              PASSWORD=${config.sops.placeholder."webdav/password"}
            '';
          };
        };
      };
    };
}
