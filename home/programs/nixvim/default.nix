{...}: {
  imports = [./keymaps.nix ./options.nix ./plugins.nix];
  programs.nixvim = {
    enable = true;
    globals.mapleader = " ";
  };
}
