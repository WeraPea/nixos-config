{
  inputs,
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
{
  imports = [
    ./firefox.nix
    ./fish.nix
    ./git.nix
    ./htop.nix
    ./hyprland.nix
    ./kitty.nix
    ./lf.nix
    ./mako.nix
    ./mpv.nix
    ./nixvim
    ./packages.nix
    ./spicetify.nix
    ./ssh.nix
    ./streamlink.nix
    ./waybar.nix
    ./nvimpager.nix
    ./vr.nix
    ./pinenote
    ./mpd.nix
    ./fcitx5.nix
    ./koreader.nix
    ./fajita
    ./quickshell
    ./wvkbd.nix
    ./mango.nix
    ./nix-search-tv.nix
  ];

  desktopPackages.enable = lib.mkIf osConfig.graphics.enable <| lib.mkDefault true;
  firefox.enable = lib.mkIf osConfig.graphics.enable <| lib.mkDefault true;
  fish.enable = lib.mkDefault true;
  git.enable = lib.mkDefault true;
  htop.enable = lib.mkDefault true;
  kitty.enable = lib.mkDefault true;
  lf.enable = lib.mkDefault true;
  mako.enable = lib.mkIf osConfig.graphics.enable <| lib.mkDefault true;
  mpv.enable = lib.mkIf osConfig.graphics.enable <| lib.mkDefault true;
  nixvim.enable = lib.mkDefault true;
  spicetify.enable = lib.mkIf config.desktopPackages.enable <| lib.mkDefault true;
  streamlink.enable = lib.mkIf config.desktopPackages.enable <| lib.mkDefault true;
  mpd.enable = lib.mkIf config.desktopPackages.enable <| lib.mkDefault true;
  fcitx5.enable = lib.mkIf osConfig.graphics.enable <| lib.mkDefault true;
  nix-search-tv.enable = lib.mkDefault true;

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
    nix-index-database.comma.enable = true;
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
  xdg.portal = lib.mkIf osConfig.graphics.enable {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
    configPackages = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  services = {
    cliphist.enable = lib.mkIf osConfig.graphics.enable <| lib.mkDefault true;
  };
}
