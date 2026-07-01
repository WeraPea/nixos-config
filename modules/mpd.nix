let
  moduleName = "mpd";
in
{
  flake.modules.${moduleName}.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.werapi.${moduleName};
    in
    {
      options.werapi.${moduleName} = {
        enable = lib.mkOption {
          default = false;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
        server = lib.mkEnableOption "server mode";
        serverHostname = lib.mkOption {
          default = "nixos";
        };
      };
      config = lib.mkIf cfg.enable {
        networking.firewall.allowedTCPPorts = [
          6600
        ]
        ++ lib.optionals cfg.server [
          20048
          2049
          111
        ];
        networking.firewall.allowedUDPPorts = lib.optionals cfg.server [
          20048
          111
        ];
        fileSystems."/mpd/musicDirectory" = lib.mkIf cfg.server {
          device = "/mnt/mnt3/music";
          fsType = "none";
          options = [ "bind" ];
        };
        fileSystems."/mpd/playlistDirectory" = lib.mkIf cfg.server {
          device = "/mnt/mnt3/music/playlists";
          fsType = "none";
          options = [ "bind" ];
        };
        fileSystems."/mnt/mpd-playlists" = lib.mkIf (!cfg.server) {
          device = "${cfg.serverHostname}:/mpd/playlistDirectory";
          fsType = "nfs";
          options = [
            "ro"
            "soft"
            "x-systemd.automount"
            "noauto"
          ];
        }; # TODO: fix nfs on fajita

        services.nfs.server = lib.mkIf cfg.server {
          enable = true;
          exports = ''
            /mpd *(ro,insecure,no_subtree_check,crossmnt)
          '';
        };

        hm.services.mpd = {
          enable = true;
          network.listenAddress = "any";
          musicDirectory =
            if cfg.server then "/mnt/mnt3/music/" else "nfs://${cfg.serverHostname}/mpd/musicDirectory";
          playlistDirectory = if cfg.server then "/mnt/mnt3/music/playlists/" else "/mnt/mpd-playlists";
          dbFile = null;
          extraConfig =
            if cfg.server then
              ''
                audio_output {
                  type "pipewire"
                  name "PipeWire Sound Server"
                }
                database {
                  plugin           "simple"
                  path             "/home/${config.werapi.username}/.local/share/mpd/mpd.db"
                  cache_directory  "/home/${config.werapi.username}/.local/share/mpd/cache"
                }
              ''
            else
              ''
                audio_output {
                  type "pipewire"
                  name "PipeWire Sound Server"
                }
                input_cache {
                  size "100 MB"
                }
                database {
                  plugin  "proxy"
                  host    "${cfg.serverHostname}"
                  port    "6600"
                }
              '';
        };
        # hm.services.mpdris2 = {
        #   enable = true;
        # };
        sops.secrets.listenbrainz_token = {
          owner = config.werapi.username;
        };
        hm.services.listenbrainz-mpd = {
          enable = true;
          settings.submission.token_file = config.sops.secrets.listenbrainz_token.path;
        };
        environment.systemPackages = with pkgs; [
          mpc
          rmpc
          cantata
        ];
      };
    };
}
