{lib, ...}: let
  teamNetworks = lib.range 1 9 |> map (team: "192.168.${toString team}.0/24");
  transitNetworks = lib.range 1 8 |> map (team: "192.168.9${toString team}.0/24");
  allowedNetworks = ["131.159.0.0/16"] ++ teamNetworks ++ transitNetworks;

  externalDnsServer = "1.1.1.1";
in {
  networking.nftables.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22 80 443];

    # Allow every ICMPv4/ICMPv6 type, beyond the built-in ping rules.
    extraInputRules = ''
      meta l4proto { icmp, ipv6-icmp } accept
    '';
  };

  networking.proxy = {
    default = "http://proxy.cit.tum.de:8080";
    noProxy = lib.concatStringsSep "," (
      ["localhost" "127.0.0.1" "::1"] ++ allowedNetworks
    );
  };

  networking.nftables.tables.assignment = {
    family = "inet";
    content = ''
      set allowed_networks {
        type ipv4_addr;
        flags interval;
        auto-merge;
        elements = { ${lib.concatStringsSep ", " allowedNetworks} };
      }

      # Disable tracking for incoming HTTP(S) and the server's replies.
      chain prerouting_raw {
        type filter hook prerouting priority raw; policy accept;
        tcp dport { 80, 443 } notrack

        # Even unsolicited ICMP must reach the ICMP allow rule, rather
        # than the generated firewall's conntrack-invalid drop rule.
        meta l4proto { icmp, ipv6-icmp } notrack
      }

      chain output_raw {
        type filter hook output priority raw; policy accept;
        tcp sport { 80, 443 } notrack
      }

      chain output {
        type filter hook output priority filter; policy drop;

        oifname "lo" accept
        meta l4proto { icmp, ipv6-icmp } accept
        ct state established,related accept

        # Allow DHCP discovery and renewal on the VirtualBox NAT network.
        ip daddr { 10.0.2.0/24, 255.255.255.255 } udp sport 68 udp dport 67 accept

        # DHCP server replies, including broadcasts to unconfigured clients.
        oifname "enp0s8" udp sport 67 udp dport 68 accept

        # Stateless replies from our HTTP(S) ports.
        ct state untracked tcp sport { 80, 443 } accept

        # All protocols and ports to the required internal networks.
        ip daddr @allowed_networks accept

        # LRZ PAC download and the proxy selected by http://pac.lrz.de.
        ip daddr 129.187.254.50 tcp dport 80 accept
        ip daddr 129.187.254.49 tcp dport 8080 accept

        # One explicitly permitted external address, for DNS only.
        ip daddr ${externalDnsServer} udp dport 53 accept
        ip daddr ${externalDnsServer} tcp dport 53 accept

        # Fail immediately for blocked outgoing traffic.
        counter reject with icmpx type admin-prohibited
      }
    '';
  };
}
