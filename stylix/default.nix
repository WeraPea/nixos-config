{ pkgs, ... }:
{
  stylix = {
    enable = true;
    image = ./wallpaper.png;
    base16Scheme = ./molokai.yaml;
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono NFM";
      };
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
    opacity = {
      applications = 0.8;
      desktop = 0.8;
      popups = 0.8;
      # terminal = 0.26;
      terminal = 1.0;
    };
  };
}
