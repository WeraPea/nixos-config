final: prev: {
  mpvScripts = prev.mpvScripts // {
    autosubsync-mpv = prev.mpvScripts.autosubsync-mpv.overrideAttrs (old: {
      src = final.fetchFromGitHub {
        owner = "WeraPea";
        repo = "autosubsync-mpv";
        rev = "0216bd95a39cf51e059b25d918a087cc402df72e";
        hash = "sha256-IrlyzzoRMdP6/kQBR+1S6WsMZnDozuu0n8oGFei3cNM=";
      };
    });
  };
}
