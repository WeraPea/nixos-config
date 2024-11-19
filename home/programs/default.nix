{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
{
  imports = [
    ./fish.nix
    ./git.nix
    ./htop.nix
    ./hyprland.nix
    ./kitty.nix
    ./lf.nix
    ./mako.nix
    ./mpv.nix
    ./nixvim
    ./spicetify.nix
    ./firefox.nix
    ./waybar.nix
    ./packages.nix
  ];

  desktopPackages.enable = lib.mkIf osConfig.graphics.enable <| lib.mkDefault true;
  firefox.enable = lib.mkIf osConfig.graphics.enable <| lib.mkDefault true;
  fish.enable = lib.mkDefault true;
  git.enable = lib.mkDefault true;
  htop.enable = lib.mkDefault true;
  hyprland.enable = lib.mkIf config.desktopPackages.enable <| lib.mkDefault true;
  kitty.enable = lib.mkDefault true;
  lf.enable = lib.mkDefault true;
  mako.enable = lib.mkIf osConfig.graphics.enable <| lib.mkDefault true;
  mpv.enable = lib.mkIf osConfig.graphics.enable <| lib.mkDefault true;
  nixvim.enable = lib.mkDefault true;
  spicetify.enable = lib.mkIf config.desktopPackages.enable <| lib.mkDefault true;
  waybar.enable = lib.mkIf config.desktopPackages.enable <| lib.mkDefault true;

  home.shellAliases = {
    cp = "cp -rip";
    mv = "mv -i";
    rm = "rm -i";
    cl = "clear";
    dc = "cd";
    lc = "clear";
    ls = "ll";
    ns = "sudo nixos-rebuild switch --flake ~/nixos-config";
    nt = "sudo nixos-rebuild test --flake ~/nixos-config";
    sl = "ll";
    vim = "nvim";
    vm = "mv";
    x = "exit";
  };
  gtk.enable = lib.mkIf osConfig.graphics.enable <| lib.mkDefault true;
  programs = {
    aria2.enable = lib.mkDefault true;
    bash.enable = lib.mkDefault true;
    jq.enable = lib.mkDefault true;
    nix-index.enable = lib.mkDefault true;
    command-not-found.enable = lib.mkIf config.programs.nix-index.enable <| false;
    zathura.enable = lib.mkIf osConfig.graphics.enable <| lib.mkDefault true;
    bat = {
      enable = lib.mkDefault true;
      extraPackages = with pkgs.bat-extras; [
        batdiff
        batwatch
      ];
      config.paging = "never";
    };
    eza = {
      enable = lib.mkDefault true;
      git = true;
      icons = "auto";
      extraOptions = [ "--group-directories-first" ];
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
  services = {
    cliphist.enable = lib.mkIf osConfig.graphics.enable <| lib.mkDefault true;
    kdeconnect = {
      enable = lib.mkIf osConfig.graphics.enable <| lib.mkDefault true;
      indicator = true;
    };
  };
}
