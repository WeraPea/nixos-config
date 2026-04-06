final: prev: {
  ffsubsync = prev.ffsubsync.overrideAttrs (old: {
    patches = old.patches or [ ] ++ [
      (final.fetchpatch {
        url = "https://github.com/WeraPea/ffsubsync/commit/be3691f5134db3b665035061acb1f7d79ca5aa91.patch";
        hash = "sha256-9UJtwVxrjoN1O7bseWDOuvaqEARaEVyTY1Y9qO+B/ys=";
      })
    ]; # can't easily override src as ffsubsync uses versioneer
  });
}
