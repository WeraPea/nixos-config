{
  config,
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

  home.shellAliases = {
    cl = "clear";
    dc = "cd";
    lc = "clear";
    ls = "ll";
    ns = "sudo nixos-rebuild switch --flake ~/nixos#nixos";
    nt = "sudo nixos-rebuild test --flake ~/nixos#nixos";
    sl = "ll";
    vim = "nvim";
    vm = "mv";
    x = "exit";
  };
  gtk.enable = true;
  stylix.targets.waybar.enable = false;
  programs = {
    aria2.enable = true;
    bash.enable = true;
    command-not-found.enable = false;
    jq.enable = true;
    nix-index.enable = true;
    zathura.enable = true;
    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        batdiff
        batwatch
      ];
      config.paging = "never";
    };
    eza = {
      enable = true;
      git = true;
      icons = true;
      extraOptions = [ "--group-directories-first" ];
    };
    waybar = {
      enable = true;
      systemd.enable = true;
    };
  };
  services = {
    cliphist.enable = true;
  };
  systemd.user.services.hyprpaper = {
    Unit = {
      Description = "hyprpaper";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${lib.getExe pkgs.hyprpaper}";
      Restart = "always";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  home.packages = with pkgs; [
    alejandra
    appimage-run
    catimg
    comma
    firefox
    gdu
    gnumake
    hyprland-autoname-workspaces
    hyprpaper
    hyprpicker
    hyprshot
    imagemagick
    inputs.audiorelay.packages.${system}.audio-relay
    jq
    krita
    lm_sensors
    lsof
    lutris
    neofetch
    ntfs3g
    onefetch
    openjdk17
    p7zip
    pavucontrol
    playerctl
    prismlauncher
    progress
    protontricks
    protonup-qt
    python3
    qimgv
    rofi-wayland
    rsync
    steam-run
    tldr
    usbutils
    vesktop
    wget
    winetricks
    wineWowPackages.stagingFull
    # wineWowPackages.waylandFull
    wl-clipboard
    xdg-utils
    xdragon
    yt-dlp
  ];
}
