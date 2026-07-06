let
  moduleName = "misc";
in
{
  flake.modules.${moduleName}.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.werapi.${moduleName};
    in
    {
      options.werapi = {
        ${moduleName}.enable = lib.mkOption {
          default = config.werapi.defaultModules.enable;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
        defaultModules.enable = lib.mkOption {
          default = false;
          description = "Whether to enable default set of modules.";
          type = lib.types.bool;
        };
        username = lib.mkOption {
          default = "wera";
          description = "Sets username.";
          type = lib.types.str;
        };
        buildSystem = lib.mkOption {
          default = pkgs.stdenv.hostPlatform.system;
          description = "Sets buildSystem for cross compiling.";
          type = lib.types.str;
        }; # this is a mess and i probably don't need it
      };
      config = lib.mkIf cfg.enable {
        programs = {
          fuse.userAllowOther = true;
          gnupg.agent = {
            enable = true;
            enableSSHSupport = true;
          };
        };

        services = {
          fstrim.enable = true;
          speechd.enable = false;
        };

        zramSwap.enable = true;

        users.users.${config.werapi.username} = {
          extraGroups = [
            "networkmanager"
            "wheel"
            "adbusers"
            "dialout"
          ];
          isNormalUser = true;
        };

        environment.pathsToLink = [
          "/share/applications"
          "/share/xdg-desktop-portal"
        ];

        boot = lib.mkIf (pkgs.stdenv.hostPlatform.system == "x86_64-linux") {
          loader = {
            efi.canTouchEfiVariables = true;
            systemd-boot.enable = true;
          };
          supportedFilesystems = [ "ntfs" ];
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

        systemd.coredump.settings.Coredump.Storage = "none";

        nixpkgs.config.allowUnfree = true;
        nix = {
          gc.automatic = true;
          optimise.automatic = true;
          settings = {
            narinfo-cache-positive-ttl = 3600;
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
              "https://cache.nixos.org"
            ];
            trusted-public-keys = [
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            ];
          };
        };
      };
    };
}
