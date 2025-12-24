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

    systemd.coredump.extraConfig = ''
      Storage=none
    '';

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
          "https://nix-community.cachix.org"
          "https://cache.nixos.org"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };
  };
}
