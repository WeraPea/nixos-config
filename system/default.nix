{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./services.nix
    ./programs.nix
    ./boot.nix
  ];

  users.users.wera = {
    isNormalUser = true;
    extraGroups = ["networkmanager" "wheel" "adbusers"];
    openssh.authorizedKeys.keys = [
      # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
    ];
  };

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall.allowedUDPPorts = [59100 59200 59716 24454]; # for audiorelay
    firewall.allowedTCPPorts = [25565 24454];
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
    settings = {
      experimental-features = ["nix-command" "flakes"];
    };
    optimise.automatic = true;
    gc.automatic = true;
  };

  fileSystems = {
    "/mnt/2tb-mnt".label = ''Linux\x20Data'';
    "/mnt/win".label = "Windows";
    "/mnt/win".options = ["rw" "uid=1000"];
  };
  swapDevices = [
    {
      device = "/mnt/2tb-mnt/swapfile";
      size = 16 * 1024;
      options = ["nofail"];
    }
  ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
  };
  environment.variables = {
    ROC_ENABLE_PRE_VEGA = "1";
  };

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "23.11";
}
