_: {
  networking.interfaces.enp0s8.useDHCP = true;
  networking.interfaces.enp0s8.ipv4.addresses = [
    {
      address = "192.168.9.3";
      prefixLength = 24;
    }
  ];

  systemd.network.networks."40-enp0s8".dhcpV4Config = {
    # Prefer the VirtualBox NAT default route for internet access.
    RouteMetric = 2048;
    # Use the DHCP domain (psa-team9.cit.tum.de) as a DNS search suffix.
    UseDomains = true;
  };
}
