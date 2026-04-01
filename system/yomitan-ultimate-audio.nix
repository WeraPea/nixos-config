{
  config,
  pkgs,
  outputs,
  lib,
  ...
}:
let
  cfg = config.yomitan-ultimate-audio;
  inherit (lib)
    types
    mkIf
    mkOption
    mkEnableOption
    ;

  secret = types.nullOr (
    types.str
    // {
      # We don't want users to be able to pass a path literal here but
      # it should look like a path.
      check = it: lib.isString it && lib.types.path.check it;
    }
  );

  domain = "yomitan-audio.${config.domain}";
in
{
  options.yomitan-ultimate-audio = {
    enable = mkEnableOption "yomitan-ultimate-audio";
    package =
      lib.mkPackageOption outputs.packages.${pkgs.stdenv.hostPlatform.system} "yomitan-ultimate-audio"
        { };
    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "The host that yomitan-ultimate-audio will listen on.";
    };
    port = mkOption {
      type = types.port;
      default = 8787;
      description = "The port that yomitan-ultimate-audio will listen on.";
    };
    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to open the yomitan-ultimate-audio port in the firewall";
    };
    user = mkOption {
      type = types.str;
      default = "yomitan-ultimate-audio";
      description = "The user yomitan-ultimate-audio should run as.";
    };
    group = mkOption {
      type = types.str;
      default = "yomitan-ultimate-audio";
      description = "The group yomitan-ultimate-audio should run as.";
    };
    dataPath = mkOption {
      type = types.path;
      default = "/var/lib/yomitan-ultimate-audio";
    };
    audioDataPath = mkOption {
      type = types.path;
      default = "${cfg.dataPath}/yomitan-audio.db";
    };
    sqlPath = mkOption {
      type = types.path;
      default = "${cfg.dataPath}/entry_and_pitch_db.sql";
    };
    environmentFile = mkOption {
      type = secret;
      example = "/run/secrets/yomitan-ultimate-audio";
      default = null;
      description = ''
        Path of a file with extra environment variables to be loaded from disk.
        This file is not added to the nix store, so it can be used to pass secrets to yomitan-ultimate-audio.

        API_KEYS=
        AWS_ACCESS_KEY_ID=
        AWS_SECRET_ACCESS_KEY=
      '';
    };
    environment = mkOption {
      type = types.attrsOf types.str;
      default = { };
    };
  };
  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

    services.caddy.virtualHosts."${domain}".extraConfig = ''
      reverse_proxy :${toString cfg.port}
    '';

    yomitan-ultimate-audio.environment = {
      AUTHENTICATION_ENABLED = "false";
      AWS_POLLY_ENABLED = "true"; # tts
      HOST = cfg.host;
      PORT = toString cfg.port;
      AUDIO_DATA_PATH = cfg.dataPath;
      DB_PATH = cfg.audioDataPath;
      SQL_PATH = cfg.sqlPath;
    };
    yomitan-ultimate-audio.environmentFile = config.sops.templates."yomitan-ultimate-audio.env".path;

    sops = {
      secrets."yomitan-ultimate-audio/aws_access_key_id" = { };
      secrets."yomitan-ultimate-audio/aws_secret_access_key" = { };
      templates."yomitan-ultimate-audio.env" = {
        owner = "yomitan-ultimate-audio";
        content = ''
          AWS_ACCESS_KEY_ID=${config.sops.placeholder."yomitan-ultimate-audio/aws_access_key_id"}
          AWS_SECRET_ACCESS_KEY=${config.sops.placeholder."yomitan-ultimate-audio/aws_secret_access_key"}
        '';
      };
    };

    systemd.services.yomitan-ultimate-audio = {
      requires = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = cfg.environment;
      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = 3;
        EnvironmentFile = cfg.environmentFile;
        StateDirectory = "yomitan-ultimate-audio";
        CacheDirectory = "yomitan-ultimate-audio";
        User = cfg.user;
        Group = cfg.group;
        ExecStartPre = pkgs.writeShellScript "yomitan-ultimate-audio-pre" ''
          if [ ! -f ${cfg.audioDataPath} ]; then
            ${cfg.package}/lib/node_modules/yomitan-audio-worker/node_modules/.bin/tsx ${cfg.package}/lib/node_modules/yomitan-audio-worker/scripts/init-local-db.ts
          fi
        '';
        ExecStart = "${cfg.package}/lib/node_modules/yomitan-audio-worker/node_modules/.bin/tsx ${cfg.package}/lib/node_modules/yomitan-audio-worker/src/server.ts";
        # will timeout if entry_and_pitch_db.sql is not wrapped with BEGIN; and COMMIT; as otherwise it writes to the file on each insert
      };
    };

    users.users = mkIf (cfg.user == "yomitan-ultimate-audio") {
      yomitan-ultimate-audio = {
        name = "yomitan-ultimate-audio";
        group = cfg.group;
        isSystemUser = true;
      };
    };
    users.groups = mkIf (cfg.group == "yomitan-ultimate-audio") { yomitan-ultimate-audio = { }; };
  };
}
