{pkgs, ...}: {
  stylix = {
    image = ./wallpaper.png;
    base16Scheme = ./molokai.yaml;
    fonts = {
      monospace.package = pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];};
      monospace.name = "JetBrains NFM";
      sizes = {
        applications = 14;
        desktop = 12;
        popups = 12;
        terminal = 13;
      };
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };
    opacity.applications = 0.8;
    opacity.desktop = 0.8;
    opacity.popups = 0.8;
    opacity.terminal = 0.26;
  };
}
