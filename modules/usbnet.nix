let
  moduleName = "usbnet";
in
{
  flake.modules.${moduleName}.nixos =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.werapi.${moduleName};
      hosts = builtins.filter (d: d.type == "host") (builtins.attrValues cfg.devices);
      devs = builtins.filter (d: d.type == "dev") (builtins.attrValues cfg.devices);
      configureFor = lib.head (
        builtins.filter (d: d.hostname == cfg.configureFor) (builtins.attrValues cfg.devices)
      );
      isHost = configureFor.type == "host";
      isDev = configureFor.type == "dev";
      mkHex = n: lib.fixedWidthString 2 "0" (lib.toHexString n);
      mkIp = dev: host: "10.55.${toString dev.id}.${toString host.id}";
      mkMac = dev: n: "02:00:10:55:${mkHex dev.id}:${mkHex n}";
      mkNetConfig = name: ip: mac: {
        links."10-${name}" = {
          matchConfig.MACAddress = mac;
          linkConfig.Name = "${name}0";
        };
        networks = {
          "10-${name}" = {
            matchConfig.MACAddress = mac;
            address = [ "${ip}/24" ];
            networkConfig.ConfigureWithoutCarrier = true;
          };
        };
      };
      netConfig =
        if isHost then
          lib.foldl' lib.recursiveUpdate { } (
            map (d: (mkNetConfig "${d.hostname}-usb" (mkIp d configureFor) (mkMac d 2))) devs
          )
        else
          mkNetConfig "usb" (mkIp configureFor configureFor) (mkMac configureFor 1);
    in
    {
      options.werapi.${moduleName} = {
        enable = lib.mkOption {
          default = false;
          description = "Whether to enable ${moduleName}.";
          type = lib.types.bool;
        };
        configureFor = lib.mkOption {
          default = config.werapi.hostname;
          description = "Which host to configure for.";
          type = lib.types.str;
        };
        devices = lib.mkOption {
          default = { };
          type = lib.types.lazyAttrsOf (
            lib.types.submodule (
              { name, ... }:
              {
                options = {
                  hostname = lib.mkOption {
                    default = name;
                    description = "Sets device hostname.";
                    type = lib.types.str;
                  };
                  id = lib.mkOption {
                    type = lib.types.ints.between 1 254;
                    description = "Sets device id.";
                  };
                  type = lib.mkOption {
                    type = lib.types.enum [
                      "host"
                      "dev"
                    ];
                    description = "Sets device type.";
                  };
                };
              }
            )
          );
        };
      };
      config = lib.mkIf cfg.enable {
        werapi.usbnet.devices = {
          pinenote = {
            id = 1;
            type = "dev";
          };
          fajita = {
            id = 2;
            type = "dev";
          };
          nixos = {
            id = 3;
            type = "host";
          };
        };

        networking.networkmanager.unmanaged = lib.mkIf isHost (map (d: "mac:${mkMac d 2}") devs); # gadget already unmanaged by default
        networking.hosts =
          if isHost then
            lib.listToAttrs (map (d: lib.nameValuePair (mkIp d d) [ "${d.hostname}-usb" ]) devs)
          else
            lib.listToAttrs (map (h: lib.nameValuePair (mkIp configureFor h) [ "${h.hostname}-usb" ]) hosts);

        systemd.network = {
          enable = true;
          wait-online.ignoredInterfaces = lib.mapAttrsToList (n: v: v.linkConfig.Name) netConfig.links;
        }
        // netConfig;

        systemd.services.usb-network-gadget = lib.mkIf isDev {
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            g=/sys/kernel/config/usb_gadget/net
            mkdir -p $g/strings/0x409 $g/configs/c.1 $g/functions/ncm.usb0
            echo 0x1d6b > $g/idVendor
            echo 0x0104 > $g/idProduct
            echo net > $g/strings/0x409/product
            echo ${mkMac configureFor 1} > $g/functions/ncm.usb0/dev_addr
            echo ${mkMac configureFor 2} > $g/functions/ncm.usb0/host_addr
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
