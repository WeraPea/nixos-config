{
  services.dnsmasq = {
    enable = true;
    settings = {
      no-hosts = true;
      no-resolv = true;
      bind-interfaces = true;
      server = [ "127.0.0.2" ]; # unbound
      listen-address = [
        "10.0.0.2"
        "127.0.0.1"
      ];
      address = [ "/server/10.0.0.2" ];
      dhcp-range = [ "10.0.0.3,10.0.0.254,24h" ];
      dhcp-option = [ "3,10.0.0.1" ];
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

  networking = {
    firewall = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [
        53
        67
      ];
    };
    defaultGateway = "10.0.0.1";
    interfaces.enp7s0.ipv4.addresses = [
      {
        address = "10.0.0.2";
        prefixLength = 24;
      }
    ];
    networkmanager.unmanaged = [ "enp7s0" ];
  };
}
