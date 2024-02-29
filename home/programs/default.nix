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
    ./git.nix
    ./eww
    ./nixvim
  ];

  # nixpkgs.overlays = [outputs.overlays.unstable-packages];

  gtk.enable = true;
  stylix.targets.waybar.enable = false;
  programs = {
    zathura.enable = true;
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
  systemd.user.services.hyprpaper = {
    Unit = {
      Description = "hyprpaper";
      After = ["graphical-session-pre.target"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${lib.getExe pkgs.hyprpaper}";
      Restart = "always";
    };
    Install = {WantedBy = ["graphical-session.target"];};
  };

  home.packages = with pkgs; [
    alejandra
    python3
    gnumake
    yt-dlp
    onefetch
    gping
    imagemagick
    catimg
    wget
    jq
    rsync
    bottom
    vesktop
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
    firefox
    gdu
    steam-run
    lutris
    lsof
    ntfs3g
    hyprshot
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
    osu-lazer-bin
    yuzu-early-access
    inputs.audiorelay.packages.${system}.audio-relay
  ];
}
