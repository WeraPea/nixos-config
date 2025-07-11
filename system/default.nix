{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    ./programs.nix
    ./services.nix
    ./hardware.nix
  ];
  options = {
    user.username = lib.mkOption { description = "Sets username"; };
    user.hostname = lib.mkOption { description = "Sets hostname"; };
    graphics.enable = lib.mkEnableOption { description = "Enables gui"; };
  };
  config = {
    graphics.enable = lib.mkDefault true;
    gaming.enable = lib.mkDefault false;
    sql.enable = lib.mkDefault false;
    user.username = lib.mkDefault "wera";

    users.users.${config.user.username} = {
      extraGroups = [
        "video"
        "networkmanager"
        "wheel"
        "adbusers"
        "dialout"
        "gamemode"
      ];
      isNormalUser = true;
    };
    environment.pathsToLink = [
      "/share/fish"
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];

    networking = {
      firewall = {
        # TODO:
        allowedTCPPorts = [
          9500
          25565
          24454 # simple voice chat
        ];
        allowedUDPPorts = [
          59100
          59200
          59716
          24454 # simple voice chat
          34197 # factorio
        ]; # for audiorelay (some)
      };
      hostName = config.user.hostname;
      networkmanager.enable = true;
    };

    time.timeZone = "Europe/Warsaw";

    console.keyMap = "pl2";
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "pl_PL.UTF-8";
      LC_IDENTIFICATION = "pl_PL.UTF-8";
      LC_MEASUREMENT = "pl_PL.UTF-8";
      LC_MONETARY = "pl_PL.UTF-8";
      LC_NAME = "pl_PL.UTF-8";
      LC_NUMERIC = "pl_PL.UTF-8";
      LC_PAPER = "pl_PL.UTF-8";
      LC_TELEPHONE = "pl_PL.UTF-8";
      LC_TIME = "pl_PL.UTF-8";
    };
    security.polkit.enable = lib.mkIf config.graphics.enable true;
    security.rtkit.enable = true;

    nixpkgs.config.allowUnfree = true;
    nix = {
      gc.automatic = true;
      optimise.automatic = true;
      settings = {
        trusted-users = [
          "@wheel"
          "root"
        ];
        experimental-features = [
          "nix-command"
          "flakes"
          "pipe-operators"
        ];
        substituters = [
          "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=10"
          "https://nix-community.cachix.org"
          "https://hyprland.cachix.org"
          "https://cache.nixos.org"
          "https://pinenote-packages.cachix.org"
          "https://rakuyomi.cachix.org"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "pinenote-packages.cachix.org-1:kikxnRWwjP5M1jWa31XlRqEkKFC4y8z+GlEtk2hCrII="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "rakuyomi.cachix.org-1:rUqRr5gnBtceig+rg1ZKrj7RsLBrj/7uiq/2qJA3zxU="
        ];
      };
    };
  };
}
