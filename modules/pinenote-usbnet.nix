let
  moduleName = "pinenote-usbnet";
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
      options.werapi.${moduleName} = {
        enable = lib.mkOption {
          default = cfg.host.enable || cfg.dev.enable;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
        host.enable = lib.mkOption {
          default = false;
          description = "Whether to enable ${moduleName} host config.";
          type = lib.types.bool;
        };
        dev.enable = lib.mkOption {
          default = false;
          description = "Whether to enable ${moduleName} dev config.";
          type = lib.types.bool;
        };
      };
      config = lib.mkIf cfg.enable {
        networking.networkmanager.unmanaged = lib.mkIf cfg.host.enable [ "mac:02:10:55:00:00:01" ]; # gadget already unmanaged by default
        networking.firewall.interfaces.usb0.allowedUDPPorts = lib.mkIf cfg.dev.enable [ 67 ];
        networking.hosts = {
          "10.55.0.1" = [ "host-usb" ];
          "10.55.0.2" = [ "pinenote-usb" ];
        };

        systemd.network = {
          enable = true;
          wait-online.enable = false;
          links."10-pinenote" = lib.mkIf cfg.host.enable {
            matchConfig.MACAddress = "02:10:55:00:00:01";
            linkConfig.Name = "pinenote0";
          };
          networks = {
            "10-usb" = lib.mkIf cfg.dev.enable {
              matchConfig.Name = "usb0";
              address = [ "10.55.0.2/24" ];
              networkConfig = {
                ConfigureWithoutCarrier = true;
                DHCPServer = true;
              };
              dhcpServerConfig = {
                PoolOffset = 1; # 10.55.0.1
                PoolSize = 1;
                EmitRouter = false;
                EmitDNS = false;
                DefaultLeaseTimeSec = "7d";
                MaxLeaseTimeSec = "7d";
              };
            };
            "10-pinenote" = lib.mkIf cfg.host.enable {
              matchConfig.MACAddress = "02:10:55:00:00:01";
              networkConfig = {
                DHCP = "ipv4";
              };
            };
          };
        };

        systemd.services.usb-network-gadget = lib.mkIf cfg.dev.enable {
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          path = [ pkgs.kmod ];
          script = ''
            modprobe libcomposite
            g=/sys/kernel/config/usb_gadget/net
            mkdir -p $g/strings/0x409 $g/configs/c.1 $g/functions/ncm.usb0
            echo 0x1d6b > $g/idVendor
            echo 0x0104 > $g/idProduct
            echo net > $g/strings/0x409/product
            echo 02:10:55:00:00:02 > $g/functions/ncm.usb0/dev_addr
            echo 02:10:55:00:00:01 > $g/functions/ncm.usb0/host_addr
            test -e $g/configs/c.1/ncm.usb0 || ln -s $g/functions/ncm.usb0 $g/configs/c.1/
            ls /sys/class/udc | head -n1 > $g/UDC
          '';
          postStop = ''
            echo "" > /sys/kernel/config/usb_gadget/net/UDC
          '';
        };
      };
    };
}
