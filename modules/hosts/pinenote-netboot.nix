{
  flake,
  inputs,
  lib,
  ...
}:
let
  moduleName = "_pinenote-netboot";
in
{
  flake.nixosConfigurations.${lib.removePrefix "_" moduleName} = flake.lib.mkNixosConfig moduleName;
  flake.modules.${moduleName}.nixos =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    {
      imports = [ flake.nixosModules._pinenote-from-x86_64 ];
      werapi = {
        # defaultModules.enable = false;
        # misc.enable = true;
        # ssh.enable = true;
        # networking.enable = true;
        firefox.enable = false;
        koreader.enable = lib.mkForce false;
        graphics.enable = false;
      };

      system.build.script = pkgs.werapi.pkgsX86_64.writeShellScriptBin "build-flash-run-script" /* bash */ ''
        export PATH="${
          lib.makeBinPath (
            with pkgs.werapi.pkgsX86_64;
            [
              inputs.pinenote-nixos.packages.${stdenv.hostPlatform.system}.usb-helper
              iproute2
              squashfs-tools
              nbdkit
            ]
          )
        }:$PATH"
        if [ "$EUID" -ne 0 ]; then
          echo "Please run as root"
          exit 1
        fi
        toplevel=${config.system.build.toplevel};
        squashfsStore=${config.system.build.squashfsStore};
        echo "Using $toplevel and $squashfsStore"

        nixos-firewall-tool open tcp 10809
        nixos-firewall-tool open tcp 10810

        sops_tmp=$(mktemp -d)

        install -Dm 600 ${config.sops.defaultSopsFile} "$sops_tmp/${config.sops.defaultSopsFile}"
        install -Dm 600 ${config.sops.age.keyFile} "$sops_tmp/${config.sops.age.keyFile}"

        mksquashfs "$sops_tmp" "$sops_tmp/img.squashfs" -noappend
        (
          nbdkit_pid=""

          cleanup() {
            if [[ -n "$nbdkit_pid" ]] && kill -0 "$nbdkit_pid"; then
              kill -9 "$nbdkit_pid"
            fi
          }

          trap cleanup EXIT

          while true; do
            until ip -o -4 addr show | grep -q 'inet 10.55.0.1/'; do
              sleep 1
            done

            nbdkit -r file "$sops_tmp/img.squashfs" -p 10810 -f -i 10.55.0.1 &
            nbdkit_pid=$!

            while kill -0 "$nbdkit_pid" && ip -o -4 addr show | grep -q 'inet 10.55.0.1/'; do
              sleep 1
            done

            cleanup
            nbdkit_pid=""
          done
        ) &
        nbdkit_pid=$!
        trap 'kill "$nbdkit_pid"; rm "$sops_tmp" -rf' EXIT

        usb-helper -n -t "$toplevel" -s "$squashfsStore"
      '';

      boot.initrd.systemd.services.nbd-sops = {
        wantedBy = [ "initrd.target" ];
        after = [
          "systemd-modules-load.service"
          "systemd-networkd.service"
          "usb-network-gadget.service"
        ];
        unitConfig.DefaultDependencies = false;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          export PATH="${lib.makeBinPath [ pkgs.nbd ]}:$PATH"
          until nbd-client 10.55.0.1 10810 /dev/nbd1; do sleep 2; done
        '';
      };
      fileSystems."/run/sops-image" = {
        device = "/dev/nbd1";
        fsType = "squashfs";
        neededForBoot = true;
      };
      fileSystems."${config.sops.defaultSopsFile}" = {
        device = "/run/sops-image${config.sops.defaultSopsFile}";
        fsType = "none";
        neededForBoot = true;
        options = [ "bind" ];
      };
      fileSystems."${config.sops.age.keyFile}" = {
        device = "/run/sops-image${config.sops.age.keyFile}";
        fsType = "none";
        neededForBoot = true;
        options = [ "bind" ];
      };

      pinenote.netboot.enable = true;
      pinenote.netboot.squashfsPkgs = pkgs.werapi.pkgsX86_64;

      boot.initrd.systemd.emergencyAccess = true;

      services.tailscale.enable = lib.mkForce false;
    };
}
