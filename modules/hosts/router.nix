let
  moduleName = "_router";
in
{
  flake.modules.${moduleName}.nixos =
    {
      lib,
      pkgs,
      ...
    }:
    {
      services.dnsmasq = {
        enable = true;
        settings = {
          no-hosts = true;
          no-resolv = true;
          bind-interfaces = true;
          server = [ "127.0.0.2" ]; # unbound
          listen-address = [
            "192.168.1.1"
            "127.0.0.1"
          ];
          address = [ "/server/192.168.1.1" ];
          dhcp-range = [ "192.168.1.3,192.168.1.254,24h" ];
          dhcp-option = [
            "option:router,192.168.1.1"
            "option:dns-server,192.168.1.1"
          ];
          expand-hosts = true;
          domain = "lan";
        };
      };

      services.unbound = {
        enable = true;
        settings = {
          server.interface = [ "127.0.0.2" ];
          forward-zone = [
            {
              name = ".";
              forward-tls-upstream = true;
              forward-addr = [
                "9.9.9.9@853#dns.quad9.net"
                "1.1.1.1@853#cloudflare-dns.com"
              ];
            }
          ];
        };
      };

      systemd.network = {
        enable = true;
        links = {
          "10-wan" = {
            matchConfig.MACAddress = "60:e3:27:1c:e9:33";
            linkConfig.Name = "wan0";
          };
          "10-usb" = {
            matchConfig.Driver = "rndis_host cdc_ncm ipheth";
            linkConfig.Name = "usb0";
          };
        };
        networks = {
          "10-usb" = {
            matchConfig.Name = "usb0";
            networkConfig.DHCP = "ipv4";
            dhcpV4Config.RouteMetric = 1000;
            linkConfig.RequiredForOnline = "no";
          };
          "10-wan" = {
            matchConfig.Name = "wan0";
            networkConfig.DHCP = "ipv4";
            dhcpV4Config.RouteMetric = 500;
          };
        };
      };

      systemd.services.wan-failover = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        path = with pkgs; [
          iproute2 # ip
          iputils # ping
          gnugrep
        ];
        script = ''
          primary="wan0"
          usb="usb0"
          fails=0
          while true; do
            if ping -I "$primary" -c1 -W2 1.1.1.1 >/dev/null 2>&1 || ping -I "$primary" -c1 -W2 9.9.9.9 >/dev/null 2>&1; then
              fails=0
              ip route del default dev "$usb" metric 50 2>/dev/null || true
            else
              fails=$((fails + 1))
              if [ "$fails" -ge 3 ]; then
                gw=$(ip -4 route show default dev "$usb" | grep -oP 'via \K\S+' | head -n1 2>/dev/null)
                [ -n "$gw" ] && ip route replace default via "$gw" dev "$usb" metric 50
              fi
            fi
            sleep 5
          done
        '';
      };

      networking = {
        useNetworkd = true;
        firewall = {
          allowedTCPPorts = [ 53 ]; # dns
          allowedUDPPorts = [
            53 # dns
            67 # dhcp
          ];
          # too lazy to go over all modules that open firewall ports on their own:
          extraCommands = ''
            iptables -I nixos-fw 1 -i wan0 -m conntrack --ctstate NEW -j nixos-fw-refuse
            iptables -I nixos-fw 1 -i usb0 -m conntrack --ctstate NEW -j nixos-fw-refuse
          '';
          extraStopCommands = ''
            iptables -D nixos-fw -i wan0 -m conntrack --ctstate NEW -j nixos-fw-refuse 2>/dev/null || true
            iptables -D nixos-fw -i usb0 -m conntrack --ctstate NEW -j nixos-fw-refuse 2>/dev/null || true
          '';
          # ip6tables -I nixos-fw6 1 -i wan0 -m conntrack --ctstate NEW -j nixos-fw-refuse
          # ip6tables -D nixos-fw6 -i wan0 -m conntrack --ctstate NEW -j nixos-fw-refuse 2>/dev/null || true
        };
        interfaces.enp7s0.ipv4.addresses = [
          {
            address = "192.168.1.1";
            prefixLength = 24;
          }
        ];
        nat = {
          enable = true;
          internalIPs = [ "192.168.1.0/24" ];
        };
        networkmanager.enable = lib.mkForce false;
      };

      boot.kernel.sysctl = {
        "net.ipv4.ip_forward" = 1;
        # "net.ipv6.conf.all.forwarding" = 1;
      };
    };
}
