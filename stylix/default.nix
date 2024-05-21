{ pkgs, ... }:
{
  stylix = {
    image = ./wallpaper.png;
    base16Scheme = ./molokai.yaml;
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/grayscale-light.yaml";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/grayscale-dark.yaml";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
    fonts = {
      monospace.package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
      monospace.name = "JetBrainsMono NFM";
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
    # opacity.terminal = 1.0;
  };
}
