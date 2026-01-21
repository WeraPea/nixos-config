{ config, ... }:
{
  networking.firewall.allowedTCPPorts = [ 3000 ];
  services.karakeep = {
    enable = true;
    browser.enable = true;
    meilisearch.enable = true;
    environmentFile = config.sops.templates."karakeep-secrets.env".path;
    extraEnvironment = {
      API_URL = "http://127.0.0.1:3000";
      KARAKEEP_SERVER_ADDR = "http://127.0.0.1:3000";
      MEILI_ADDR = "http://${config.services.meilisearch.listenAddress}:${toString config.services.meilisearch.listenPort}";
      DISABLE_SIGNUPS = "true";
    };
  };
  services.meilisearch = {
    enable = true;
    listenAddress = "127.0.0.1";
    listenPort = 7700;
    masterKeyFile = config.sops.secrets."karakeep/meili-masterkey".path;
  };
  sops = {
    secrets = {
      "karakeep/meili-masterkey" = { };
    };

    templates."karakeep-secrets.env" = {
      owner = "karakeep";
      group = "karakeep";
      content = ''
        MEILI_MASTER_KEY=${config.sops.placeholder."karakeep/meili-masterkey"}
      '';
    };
  };
}
