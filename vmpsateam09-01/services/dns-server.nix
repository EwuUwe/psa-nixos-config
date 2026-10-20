{...}: {
  services.bind = {
    enable = true;

    listenOn = ["any"];
    listenOnIpv6 = ["any"];

    forwarders = [
      "131.159.254.1"
      "131.159.254.2"
    ];
    forward = "only";

    cacheNetworks = [
      "127.0.0.0/8"
      "::1/128"
      "192.168.9.0/24"
    ];

    extraOptions = ''
      empty-zones-enable no;

      dnssec-validation no;

      allow-transfer {
        127.0.0.1;
        ::1;
        192.168.9.0/24;
      };
    '';

    zones = {
      "psa-team09.cit.tum.de" = {
        master = true;
        file = ./zones/psa-team09.cit.tum.de.zone;
      };

      "9.168.192.in-addr.arpa" = {
        master = true;
        file = ./zones/db.192.168.9;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [53];
  networking.firewall.allowedUDPPorts = [53];
}
