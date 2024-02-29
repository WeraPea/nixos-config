{...}: {
  imports = [./keymaps.nix ./options.nix ./plugins.nix ./colorscheme.nix];
  programs.nixvim = {
    enable = true;
    globals.mapleader = " ";
  };
}
