{
  lib,
  config,
  ...
}:
{
  options = {
    beets.enable = lib.mkEnableOption "enables beets";
  };
  config = lib.mkIf config.beets.enable {
    programs.beets = {
      enable = true;
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
      };
    };
  };
}
