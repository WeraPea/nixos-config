final: prev: {
  mpvScripts = prev.mpvScripts // {
    webtorrent-mpv-hook = prev.mpvScripts.webtorrent-mpv-hook.overrideAttrs (old: {
      src = final.fetchFromGitHub {
        owner = "WeraPea";
        repo = "webtorrent-mpv-hook";
        rev = "d5c04a770ad22f166b65793da1abe99f36a21610";
        hash = "sha256-8ifGLsh+qlP/itsDbP/5K9q8/j6jgbbatDJCaL+sZQo=";
      };
    });
  };
}
