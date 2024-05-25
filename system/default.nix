{
  config,
  pkgs,
  inputs,
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
  };
  config = {
    gaming.enable = lib.mkDefault false;
    sql.enable = lib.mkDefault false;
    user.username = lib.mkDefault "wera";

    users.users.${config.user.username} = {
      extraGroups = [
        "networkmanager"
        "wheel"
        "adbusers"
        "dialout"
      ];
      isNormalUser = true;
    };

    networking = {
      firewall.allowedTCPPorts = [
        9500
        25565
        24454
        1701 # weylus
        9001 # weylus
      ];
      firewall.allowedUDPPorts = [
        59100
        59200
        59716
        24454
      ]; # for audiorelay
      hostName = config.user.hostname;
      networkmanager.enable = true;
    };
    networking.firewall = {
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        } # KDE Connect
      ];
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        } # KDE Connect
      ];
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
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
    };

    # swapDevices = [
    #   {
    #     device = "/mnt/2tb-mnt/swapfile";
    #     options = ["nofail"];
    #     size = 16 * 1024;
    #   }
    # ];

    hardware.opengl = {
      driSupport32Bit = true;
      driSupport = true;
      enable = true;
    };

    system.stateVersion = "23.11";
  };
}
