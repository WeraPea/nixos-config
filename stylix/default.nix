{
  config,
  outputs,
  pkgs,
  ...
}:
{
  stylix = {
    enable = true;
    image = ./wallpaper.png;
    base16Scheme = ./molokai.yaml;
    fonts = {
      monospace = {
        package = outputs.packages.${pkgs.stdenv.hostPlatform.system}.udev-gothic-hs-nf;
        name = "UDEV Gothic 35HSDZNFLG";
      };
      serif = config.stylix.fonts.monospace;
      sansSerif = config.stylix.fonts.monospace;
      sizes = {
        applications = 12;
        desktop = 12;
        popups = 12;
        terminal = 10;
      };
    };
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };
    opacity = {
      applications = 0.8;
      desktop = 0.8;
      popups = 0.8;
      terminal = 0.8;
    };
  };
}
