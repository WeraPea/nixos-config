final: prev: {
  bs-manager = prev.bs-manager.overrideAttrs (old: {
    desktopItems = [
      (final.makeDesktopItem {
        desktopName = "BSManager";
        name = "BSManager";
        exec = "bs-manager %u"; # add %u
        terminal = false;
        type = "Application";
        icon = "bs-manager";
        mimeTypes = [
          "x-scheme-handler/bsmanager"
          "x-scheme-handler/beatsaver"
          "x-scheme-handler/bsplaylist"
          "x-scheme-handler/modelsaber"
          "x-scheme-handler/web+bsmap"
        ];
        categories = [
          "Utility"
          "Game"
        ];
      })
    ];
  });
}
