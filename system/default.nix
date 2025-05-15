{
  config,
  lib,
  ...
}:
{
  imports = [
    ./boot.nix
    ./programs.nix
    ./services.nix
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
        "networkmanager"
        "wheel"
        "adbusers"
        "dialout"
        "gamemode"
      ];
      isNormalUser = true;
    };

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
        allowedTCPPortRanges = [
          {
            from = 1714;
            to = 1764;
          } # kdeconnect
        ];
        allowedUDPPortRanges = [
          {
            from = 1714;
            to = 1764;
          } # kdeconnect
        ];
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

    nixpkgs.config.allowUnfree = true;
    nix = {
      gc.automatic = true;
      optimise.automatic = true;
      settings = {
        trusted-users = [ config.user.username ];
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
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        ];
      };
    };

    hardware.graphics.enable = lib.mkDefault true;
    hardware.graphics.enable32Bit = lib.mkIf config.hardware.graphics.enable <| lib.mkDefault true;
  };
}
