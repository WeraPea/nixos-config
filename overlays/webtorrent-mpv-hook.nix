final: prev: {
  mpvScripts = prev.mpvScripts // {
    webtorrent-mpv-hook = prev.mpvScripts.webtorrent-mpv-hook.overrideAttrs (old: {
      patches = [ ./webtorrent-mpv-hook.patch ];
    });
  };
}
