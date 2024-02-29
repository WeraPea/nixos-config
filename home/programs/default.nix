{
  pkgs,
  outputs,
  config,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./hyprland.nix
    ./fish.nix
    ./kitty.nix
    ./mpv.nix
    ./spicetify.nix
    ./mako.nix
    ./lf.nix
    ./htop.nix
    ./eww
  ];

  nixpkgs.overlays = [outputs.overlays.unstable-packages];

  gtk.enable = true;
  stylix.targets.waybar.enable = false;
  programs = {
    command-not-found.enable = false;
    nix-index.enable = true;
    aria2.enable = true;
    jq.enable = true;
    bash.enable = true;
    waybar = {
      enable = true;
      systemd.enable = true;
    };
    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [batdiff batwatch];
      config.paging = "never";
    };
    eza = {
      enable = true;
      enableAliases = true;
      git = true;
      icons = true;
      extraOptions = ["--group-directories-first"];
    };
  };
  services = {
    cliphist.enable = true;
  };

  home.packages = with pkgs; [
    (python3.withPackages (ps: with ps; [python-lsp-server]))
    pkgs.unstable.vesktop
    (discord.override {
      withOpenASAR = true;
      withVencord = true;
    })
    qutebrowser
    wl-clipboard
    rofi-wayland
    hyprland-autoname-workspaces
    hyprpaper
    hyprpicker
    # pwvucontrol
    pavucontrol
    neofetch
    firefox # maybe also ↑
    gdu
    steam-run
    lutris
    lsof
    ntfs3g
    pkgs.unstable.hyprshot
    p7zip
    playerctl
    comma
    nixd
    wineWowPackages.stagingFull
    # wineWowPackages.waylandFull
    winetricks
    protontricks
    qimgv
    prismlauncher
    xdg-utils
    openjdk17
    krita
    lm_sensors
    pkgs.unstable.osu-lazer-bin
    pkgs.unstable.yuzu-early-access
    inputs.audiorelay.packages.${system}.audio-relay
  ];
}
