{
  flake,
  lib,
  ...
}:
let
  moduleName = "_nixos";
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
      werapi = {
        hostname = "nixos";
        defaultModules.enable = true;
        gaming.enable = true;

        beets.enable = true;
        mango = {
          mainDisplay = "DP-2";
          bindModes.default.binds.bind =
            (builtins.listToAttrs (
              builtins.concatMap (w: [
                (lib.nameValuePair "SUPER,F${w}" [
                  "focusmon,HDMI-A-1"
                  "view,${w}"
                ])
                (lib.nameValuePair "SUPER+SHIFT,F${w}" [
                  "tagmon,HDMI-A-1"
                  "tag,${w}"
                ])
              ]) (map toString (lib.range 1 5))
            ))
            // (builtins.listToAttrs (
              builtins.concatMap (w: [
                (lib.nameValuePair "SUPER,${toString (lib.mod (w + 5) 10)}" [
                  "focusmon,HDMI-A-2"
                  "view,${toString w}"
                ])
                (lib.nameValuePair "SUPER+SHIFT,${toString (lib.mod (w + 5) 10)}" [
                  "tagmon,HDMI-A-2"
                  "tag,${toString w}"
                ])
              ]) (lib.range 1 5)
            ));
        };
        mpd.enable = true;
        packages = {
          desktop.enable = true;
          gaming.enable = true;
        };
        qocr.enable = true;
        quickshell.enable = true;
        streamlink.enable = true;
        vr.enable = true;
      };

      environment.systemPackages = with pkgs; [
        (blender.withPackages (p: [ p.py-slvs ]))
        freecad
        inkscape
        mokuro
        xournalpp
      ];

      hm = {
        home.stateVersion = "23.11";
        wayland.windowManager.mango.settings = {
          syncobj_enable = 1;
          monitorrule =
            with rec {
              DP_2_x = HDMI_A_2_x + HDMI_A_2_width - HDMI_A_2_overscan_right + 1;
              DP_2_y = 0;
              DP_2_width = 2560;
              DP_2_height = 1440;

              HDMI_A_1_x = DP_2_x + DP_2_width;
              HDMI_A_1_y = DP_2_y;
              HDMI_A_1_width = 1280;
              HDMI_A_1_height = 1024;
              HDMI_A_1_overscan_bottom = 64;

              HDMI_A_2_x = 0;
              HDMI_A_2_y = DP_2_y + DP_2_height - HDMI_A_2_height + HDMI_A_2_overscan_top;
              HDMI_A_2_width = 1920;
              HDMI_A_2_height = 1080;
              HDMI_A_2_overscan_top = 25;
              HDMI_A_2_overscan_bottom = 25;
              HDMI_A_2_overscan_left = 97;
              HDMI_A_2_overscan_right = 97;
            }; [
              "name:DP-2,x:${toString DP_2_x},y:${toString DP_2_y},width:${toString DP_2_width},height:${toString DP_2_height},refresh:144"
              "name:HDMI-A-1,x:${toString HDMI_A_1_x},y:${toString HDMI_A_1_y},width:${toString HDMI_A_1_width},height:${toString HDMI_A_1_height},refresh:75,overscan_bottom:${toString HDMI_A_1_overscan_bottom}"
              "name:HDMI-A-2,x:${toString HDMI_A_2_x},y:${toString HDMI_A_2_y},width:${toString HDMI_A_2_width},height:${toString HDMI_A_2_height},refresh:60,overscan_top:${toString HDMI_A_2_overscan_top},overscan_bottom:${toString HDMI_A_2_overscan_bottom},overscan_left:${toString HDMI_A_2_overscan_left},overscan_right:${toString HDMI_A_2_overscan_right}"
            ];
        };
      };

      services.ddccontrol.enable = true;

      system.stateVersion = "23.11";
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

      networking.interfaces.enp10s0.wakeOnLan.enable = true;

      boot = {
        kernelPackages =
          let
            old-nixpkgs = import (fetchTarball {
              url = "https://github.com/NixOS/nixpkgs/archive/a82ccc39b39b621151d6732718e3e250109076fa.tar.gz";
              sha256 = "1664s8ffaa3hcvz4d4hwca2l6xl25j8dvzxwmd2ckcskcncq1zc1";
            }) { system = pkgs.stdenv.hostPlatform.system; };
          in
          old-nixpkgs.linuxPackages_6_18; # fixes bluetooth
        binfmt.emulatedSystems = [ "aarch64-linux" ];
        initrd.availableKernelModules = [
          "nvme"
          "xhci_pci"
          "ahci"
          "usbhid"
          "usb_storage"
          "sd_mod"
        ];
        kernelModules = [ "kvm-amd" ];
      };

      hardware = {
        amdgpu = {
          overdrive.enable = true;
          overdrive.ppfeaturemask = "0xffffffff";
          initrd.enable = true;
          opencl.enable = true;
        };
        enableRedistributableFirmware = true;
        cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };

      fileSystems = {
        "/boot" = {
          device = "/dev/disk/by-uuid/383C-A45C";
          fsType = "vfat";
          options = [
            "fmask=0022"
            "dmask=0022"
          ];
        };
        "/" = {
          device = "/dev/disk/by-uuid/14a0ea77-23dc-46aa-9565-a520bb458c5d";
          fsType = "btrfs";
          options = [
            "subvol=root"
            "compress=zstd"
          ];
        };
        "/home" = {
          device = "/dev/disk/by-uuid/14a0ea77-23dc-46aa-9565-a520bb458c5d";
          fsType = "btrfs";
          options = [
            "subvol=home"
            "compress=zstd"
          ];
        };
        "/nix" = {
          device = "/dev/disk/by-uuid/14a0ea77-23dc-46aa-9565-a520bb458c5d";
          fsType = "btrfs";
          options = [
            "subvol=nix"
            "compress=zstd"
            "noatime"
          ];
        };
        "/mnt/2tb-mnt" = {
          label = "Linux\\x20Data";
          fsType = "ext4";
        };
        "/mnt/win" = {
          label = "Windows";
          fsType = "ntfs";
          options = [
            "rw"
            "uid=1000"
          ];
        };
        "/mnt/mnt2" = {
          label = "Windows\\x20Data";
          fsType = "ntfs";
          options = [
            "rw"
            "uid=1000"
          ];
        };
        "/mnt/mnt3" = {
          device = "/dev/disk/by-uuid/33500f50-83b2-40b8-aa99-4a97737f52fb";
          fsType = "btrfs";
          options = [ "compress=zstd" ];
        };
      };
    };
}
