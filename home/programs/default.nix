{
  config,
  osConfig,
  inputs,
  lib,
  outputs,
  pkgs,
  ...
}:
{
  imports = [
    ./eww
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
  ];

  fish.enable = lib.mkDefault true;
  git.enable = lib.mkDefault true;
  htop.enable = lib.mkDefault true;
  hyprland.enable = lib.mkDefault true;
  kitty.enable = lib.mkDefault true;
  lf.enable = lib.mkDefault true;
  mako.enable = lib.mkDefault true;
  mpv.enable = lib.mkDefault true;
  nixvim.enable = lib.mkDefault true;
  spicetify.enable = lib.mkDefault true;

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
  gtk.enable = lib.mkDefault true;
  # stylix.targets.waybar.enable = lib.mkIf programs.waybar.enable false;
  programs = {
    aria2.enable = lib.mkDefault true;
    bash.enable = lib.mkDefault true;
    jq.enable = lib.mkDefault true;
    nix-index.enable = lib.mkDefault true;
    command-not-found.enable = lib.mkIf config.programs.nix-index.enable false;
    zathura.enable = lib.mkDefault true;
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
      icons = true;
      extraOptions = [ "--group-directories-first" ];
    };
    waybar = {
      enable = lib.mkDefault true;
      systemd.enable = true;
    };
  };
  services = {
    cliphist.enable = lib.mkDefault true;
  };

  home.packages = with pkgs; lib.mkMerge [ ([
    appimage-run
    catimg
    comma
    firefox # TODO: move to module
    gdu
    gnumake
    helvum
    imagemagick
    inputs.audiorelay.packages.${system}.audio-relay
    jq
    krita
    lm_sensors
    lsof
    neofetch
    nh
    ntfs3g
    onefetch
    openjdk17
    p7zip
    pavucontrol
    playerctl
    progress
    python3
    qimgv # TODO: move to module
    rofi-wayland # TODO: move to module
    rsync
    steam-run
    tldr
    usbutils
    vesktop
    wget
    wl-clipboard
    xdg-utils
    xdragon
    yt-dlp
  ])
  (lib.mkIf osConfig.gaming.enable [
    lutris
    prismlauncher
    protontricks
    protonup-qt
    winetricks
    wineWowPackages.stagingFull
    # wineWowPackages.waylandFull
  ])];
}
