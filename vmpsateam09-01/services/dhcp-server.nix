{lib, ...}: let
  routes =
    lib.range 1 8
    |> lib.concatMap (team: [
      "192.168.${toString team}.0/24,192.168.9.1"
      "192.168.9${toString team}.0/24,192.168.9.1"
    ]);
in {
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      port = 0; # BIND provides DNS.
      interface = "enp0s8";
      dhcp-range = "192.168.9.0,static,255.255.255.0,12h";
      dhcp-ignore = "tag:!known";
      dhcp-host = [
        "08:00:27:dc:3f:d5,id:*,192.168.9.2,vmpsateam09-02"
      ];
      dhcp-option = [
        "option:netmask,255.255.255.0"
        "option:router,192.168.9.1"
        "option:dns-server,192.168.9.1"
        "option:domain-name,psa-team9.cit.tum.de"
      ];
      dhcp-option-force = [
        # The exercise requires a default gateway. Clients using option 121
        # ignore option 3, so include the default route here too.
        "121,${lib.concatStringsSep "," (routes ++ ["0.0.0.0/0,192.168.9.1"])}"
        "252,http://pac.lrz.de"
      ];
    };
  };

  networking.firewall.interfaces.enp0s8.allowedUDPPorts = [67];
}
