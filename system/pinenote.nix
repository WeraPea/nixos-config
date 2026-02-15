{
  lib,
  pkgs,
  outputs,
  inputs,
  config,
  ...
}:
let
  pkgsCross = import inputs.pinenote-nixos.inputs.nixpkgs {
    # nixpkgs from pinenote-nixos to not rebuild the kernel when not needed
    system = "x86_64-linux";
    crossSystem = {
      config = "aarch64-unknown-linux-gnu";
    };
  };
  pkgsX86_64 = import inputs.nixpkgs {
    system = "x86_64-linux";
  };
in
{
  imports = [
    ./mango.nix
  ];
  user.hostname = "pinenote";
  pinenote.config.enable = true;
  pinenote.pinenote-service.enable = true;

  boot.kernelPackages = lib.mkIf (config.buildSystem == "x86_64-linux") (
    pkgsCross.linuxPackagesFor (
      pkgsCross.callPackage "${inputs.pinenote-nixos}/packages/pinenote-kernel.nix" { }
    )
  );
  hardware.opentabletdriver.enable = lib.mkForce false;
  system.stateVersion = "25.05";
  fileSystems."/" = {
    label = "nixos";
    fsType = "ext4";
  };
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  services.logind.settings.Login = {
    HandlePowerKey = "suspend";
    HandlePowerKeyLongPress = "poweroff";
  };

  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [
        {
          command = lib.getExe outputs.packages.${pkgs.stdenv.hostPlatform.system}.usb-tablet;
          options = [
            "SETENV"
            "NOPASSWD"
          ];
        }
      ];
    }
  ];

  services.journald.storage = "volatile";
  zramSwap.enable = true;
  stylix = {
    fonts.monospace.package = lib.mkForce (
      if (config.buildSystem == "x86_64-linux") then
        pkgsX86_64.callPackage ../pkgs/udev-gothic-hs-nf.nix { }
      else
        outputs.packages.${pkgs.stdenv.hostPlatform.system}.udev-gothic-hs-nf
    );

    cursor.name = lib.mkForce "Bibata-Modern-Ice";

    opacity = lib.mkForce {
      applications = 1.;
      desktop = 1.;
      popups = 1.;
      terminal = 1.;
    };

    base16Scheme = lib.mkForce {
      scheme = "eink-light";
      base00 = "#ffffff";
      base01 = "#eeeeee";
      base02 = "#dddddd";
      base03 = "#bbbbbb";
      base04 = "#444444";
      base05 = "#222222";
      base06 = "#111111";
      base07 = "#000000";
      base08 = "#777777";
      base09 = "#cccccc";
      base0A = "#aaaaaa";
      base0B = "#999999";
      base0C = "#888888";
      base0D = "#333333";
      base0E = "#666666";
      base0F = "#555555";
    };
  };
}
