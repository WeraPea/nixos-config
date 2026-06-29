{
  flake,
  inputs,
  lib,
  ...
}:

let
  moduleName = "_iso";
in
{
  flake.nixosConfigurations.${lib.removePrefix "_" moduleName} = flake.lib.mkNixosConfig moduleName;
  flake.modules.${moduleName}.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
      ];

      werapi = {
        hostname = "iso";
        defaultModules.enable = true;
      };

      environment.systemPackages = with pkgs; [
        android-tools
        brightnessctl
        dragon-drop
        steam-run
        tmux
      ];

      hm.home.stateVersion = config.system.stateVersion;

      fonts.fontconfig.enable = lib.mkForce true;
      networking.useDHCP = lib.mkDefault true;

      users.users.wera.initialPassword = "12345";

      boot = {
        supportedFilesystems = lib.mkForce [
          "btrfs"
          "reiserfs"
          "vfat"
          "f2fs"
          "xfs"
          "ntfs"
          "cifs"
        ];
      };
      nixpkgs.hostPlatform = "x86_64-linux";

      isoImage.edition = "graphical";
      isoImage.configurationName = "Mango (Linux ${config.boot.kernelPackages.kernel.version})";
    };
}
