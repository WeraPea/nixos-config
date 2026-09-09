{
  flake,
  ...
}:
let
  moduleName = "beets";
in
{
  flake.wrappers.beets =
    {
      pkgs,
      ...
    }:
    {
      # package = (
      #   (pkgs.python3.pkgs.beets.override {
      #     pluginOverrides = {
      #       vocadb = {
      #         enable = true;
      #         propagatedBuildInputs = [ pkgs.werapi.beets-vocadb ];
      #       };
      #     };
      #   }).overrideAttrs
      #     { doInstallCheck = false; }
      # );
      package = (
        # workaround: for whatever reason the above decided to ignore the plugin override after an update
        pkgs.python3.pkgs.beets.overrideAttrs (old: {
          propagatedBuildInputs = old.propagatedBuildInputs ++ [ pkgs.werapi.beets-vocadb ];
          doInstallCheck = false;
        })
      );
      settings = {
        directory = "/mpd/music/beets";
        plugins = [
          "chroma" # do i even use this?
          "embedart" # not for singletons
          "fetchart"
          "fromfilename"
          "mpdstats" # TODO: config this (service)
          "mpdupdate"
          "musicbrainz"
          "smartplaylist"
          "edit"
          "vocadb"
          "utaitedb"
          "touhoudb"
          "play"
        ];
        musicbrainz = {
          genres = true;
        };
        smartplaylist = {
          playlist_dir = "/mpd/music/playlists";
          playlists = [
            {
              name = "all.m3u";
              query = "";
            }
          ];
        };
        match.preffered = {
          countries = [ "JP" ];
          media = [
            "Digital Media|File"
            "CD"
          ];
          original_year = true;
        };
        play = {
          relative_to = "/mpd/music";
          warning_threshold = false;
          command = pkgs.writeShellScript "beet-play" ''
            printf '<%q>\n' "$@"
            no_clear=""
            online=""
            host="localhost"

            while [[ $# -gt 1 ]]; do
              case "$1" in
              no-clear)
                no_clear="yes"
                shift
                ;;
              host)
                host="$2"
                shift 2
                ;;
              online)
                online="yes"
                shift
                ;;
              *)
                echo invalid argument >&2
                exit 1
                ;;
              esac
            done
            if [ -z "$no_clear" ]; then
              mpc -h "$host" clear >/dev/null
            fi
            cp "''${!#}" /mpd/music/playlists/beet-play.m3u
            if [ "$host" != "localhost" ]; then
              if [ -z "$online" ]; then
                ssh "$host" mpd-playlists-remote-to-local # assumes /mpd/ is mounted
                mpc -h "$host" load beet-play-sync
              else
                ssh "$host" 'sed -e "s|^|$HOME/music/sync/&|" /mpd/music/playlists/beet-play.m3u > $HOME/music/playlists/beet-play.m3u' # assumes /mpd/ is mounted
                mpc -h "$host" load beet-play
              fi
            else
              mpc -h "$host" load beet-play
            fi
            mpc -h "$host" play
          '';
        };
      };
    };
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
      imports = [
        flake.wrappers.beets.install
      ];
      options.werapi.${moduleName} = {
        enable = lib.mkOption {
          default = false;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
      };
      config = lib.mkIf cfg.enable {
        wrappers.beets.enable = true;
      };
    };
}
