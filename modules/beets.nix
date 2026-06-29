let
  moduleName = "beets";
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
      };
      config = lib.mkIf cfg.enable {
        hm.programs.beets = {
          enable = true;
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
            directory = "/mnt/mnt3/music/beets";
            plugins = [
              "chroma" # do i even use this?
              "embedart" # not for singletons
              "fetchart"
              "fromfilename"
              "mpdstats"
              "mpdupdate"
              "musicbrainz"
              "smartplaylist"
              "edit"
              "vocadb"
              "utaitedb"
              "touhoudb"
            ];
            musicbrainz = {
              genres = true;
            };
            smartplaylist = {
              playlist_dir = "/mnt/mnt3/music/playlists";
              relative_to = "/mnt/mnt3/music/";
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
          };
        };
      };
    };
}
