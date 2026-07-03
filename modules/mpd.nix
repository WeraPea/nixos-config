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
        fileSystems."/mpd/music" = lib.mkIf cfg.server {
          device = "/mnt/mnt3/music";
          fsType = "none";
          options = [ "bind" ];
        };
        fileSystems."/mpd" = lib.mkIf (!cfg.server) {
          device = "${cfg.serverHostname}:/mpd/";
          fsType = "nfs";
          options = [
            "ro"
            "soft"
            "x-systemd.automount"
            "noauto"
          ];
        };

        services.nfs.server = lib.mkIf cfg.server {
          enable = true;
          exports = ''
            /mpd *(ro,insecure,no_subtree_check,crossmnt)
          '';
        };

        hm.services.mpd = {
          enable = true;
          network.listenAddress = "any";
          musicDirectory = if cfg.server then "/mpd/music" else "/home/${config.werapi.username}/music";
          playlistDirectory =
            if cfg.server then "/mpd/music/playlists" else "/home/${config.werapi.username}/music/playlists";
          extraConfig = ''
            audio_output {
              type "pipewire"
              name "PipeWire Sound Server"
            }
            save_absolute_paths_in_playlists "yes"
          '';
        };
        hm.services.mpdris2 = {
          enable = true;
        };
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
          (pkgs.writeShellScriptBin "mpd-playlists-remote-to-local" ''
            out_dir=/home/${config.werapi.username}/music/playlists/
            sync_music_dir=/home/${config.werapi.username}/music/sync/
            mkdir -p "$out_dir"
            for f in /mpd/music/playlists/*; do
              basename=$(basename $f)
              case $f in
                *.*) filename="''${basename%.*}-sync.''${basename##*.}" ;;
                *) filename="''${basename}-sync" ;;
              esac
              sed -e "s|^/mpd/music/|$sync_music_dir|" "$f" > "$out_dir"/$filename
            done
          '') # for offline copy
        ];
      };
    };
}
