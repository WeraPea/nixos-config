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
    ./hardware-configuration.nix
    ./programs.nix
    ./services.nix
  ];

  users.users.wera = {
    extraGroups = [
      "networkmanager"
      "wheel"
      "adbusers"
      "dialout"
    ];
    isNormalUser = true;
    # openssh.authorizedKeys.keys = [
    #   # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
    # ];
  };

  networking = {
    firewall.allowedTCPPorts = [
      9500
      25565
      24454
    ];
    firewall.allowedUDPPorts = [
      59100
      59200
      59716
      24454
    ]; # for audiorelay
    hostName = "nixos";
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
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  fileSystems = {
    "/mnt/2tb-mnt".label = "Linux\\x20Data";
    "/mnt/win" = {
      label = "Windows";
      options = [
        "rw"
        "uid=1000"
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
  zramSwap.enable = true;

  hardware.opengl = {
    driSupport32Bit = true;
    driSupport = true;
    enable = true;
    extraPackages = with pkgs; [ rocmPackages.clr.icd ];
  };

  system.stateVersion = "23.11";
}
