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
  boot.kernelPatches = [
    {
      name = "enable swap"; # required for zswap to be enabled
      patch = null;
      structuredExtraConfig = with lib.kernel; {
        SWAP = yes;
      };
    }
  ];
  hardware.graphics.enable32Bit = lib.mkForce false;
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

    # base16Scheme = "${pkgs.base16-schemes}/share/themes/grayscale-light.yaml";
    base16Scheme = lib.mkForce {
      scheme = "eink-light";
      base00 = "#ffffff";
      base01 = "#e3e3e3";
      base02 = "#b9b9b9";
      base03 = "#ababab";
      base04 = "#525252";
      base05 = "#464646";
      base06 = "#252525";
      base07 = "#000000";
      base08 = "#7c7c7c";
      base09 = "#999999";
      base0A = "#a0a0a0";
      base0B = "#8e8e8e";
      base0C = "#868686";
      base0D = "#686868";
      base0E = "#747474";
      base0F = "#5e5e5e";
    };
  };
}
