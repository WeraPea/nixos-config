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
