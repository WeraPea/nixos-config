let
  moduleName = "networking";
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
    in
    {
      options.werapi = {
        ${moduleName}.enable = lib.mkOption {
          default = config.werapi.defaultModules.enable;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
        hostname = lib.mkOption {
          description = "Sets hostname.";
          type = lib.types.str;
        };
        domain = lib.mkOption {
          description = "Sets domain.";
          type = lib.types.str;
        };
      };
      config = lib.mkIf cfg.enable {
        programs.mtr.enable = true;
        services.tailscale = {
          enable = true;
          extraSetFlags = [
            "--hostname=${config.networking.hostName}-ts"
          ];
        };

        sops = {
          secrets."wifi/home/psk" = { };
          secrets."wifi/home/ssid" = { };
          templates."nm-wifi-env" = {
            content = ''
              WIFI_HOME_PSK=${config.sops.placeholder."wifi/home/psk"}
              WIFI_HOME_SSID=${config.sops.placeholder."wifi/home/ssid"}
            '';
            owner = "root";
            group = "root";
            mode = "0400";
          };
        };

        networking = {
          hostName = config.werapi.hostname;
          networkmanager = {
            enable = true;
            ensureProfiles = {
              environmentFiles = [ config.sops.templates."nm-wifi-env".path ];
              profiles.home-net = {
                connection = {
                  id = "home-net";
                  type = "wifi";
                };
                wifi = {
                  mode = "infrastructure";
                  ssid = "$WIFI_HOME_SSID";
                };
                wifi-security = {
                  auth-alg = "open";
                  key-mgmt = "wpa-psk";
                  psk = "$WIFI_HOME_PSK";
                };
                ipv4 = {
                  method = "auto";
                };
                ipv6 = {
                  addr-gen-mode = "default";
                  method = "auto";
                };
              };
            };
          };
        };
      };
    };
}
