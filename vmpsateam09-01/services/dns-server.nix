{lib, ...}: let
  # DNS server IP for each team (index 1 to 9).
  teamDnsServers = [
    "192.168.1.1"
    "192.168.2.10"
    "192.168.3.1"
    "192.168.4.2"
    "192.168.5.2"
    "192.168.6.1"
    "192.168.7.3"
    "192.168.8.11"
    "192.168.9.1"
  ];

  teamDns = team: lib.elemAt teamDnsServers (team - 1);

  teamForwardZones = lib.concatMapStrings (team: ''
    zone "psa-team${toString team}.cit.tum.de" {
      type forward;
      forward only;
      forwarders { ${teamDns team}; };
    };
  '') (lib.range 2 7);

  remoteReverseZones = lib.concatMapStrings (team: ''
    zone "${toString team}.168.192.in-addr.arpa" {
      type forward;
      forward only;
      forwarders { ${teamDns team}; };
    };
  '') (lib.range 2 7);

  masterZone = file: {
    inherit file;
    master = true;
    slaves = [
      "127.0.0.1"
      "::1"
      "192.168.0.0/16"
    ];
  };
in {
  services.bind = {
    enable = true;

    listenOn = ["127.0.0.1" "192.168.9.1"];
    listenOnIpv6 = ["none"];

    # Internal CIT/ITO nameservers.
    forwarders = [
      "131.159.254.1"
      "131.159.254.2"
    ];
    forward = "only";

    # Client networks allowed to use recursive resolution and cached answers.
    cacheNetworks = [
      "127.0.0.0/8"
      "::1/128"
      "192.168.0.0/16"
    ];

    extraOptions = ''
      empty-zones-enable no;
      dnssec-validation no;

      allow-transfer {
        127.0.0.1;
        ::1;
        192.168.0.0/16;
      };

      also-notify {
        ${teamDns 8};
        ${teamDns 1};
      };
    '';

    extraConfig = teamForwardZones + remoteReverseZones;

    zones = {
      "psa-team9.cit.tum.de" = masterZone ./zones/psa-team9.cit.tum.de.zone;
      "9.168.192.in-addr.arpa" = masterZone ./zones/db.192.168.9;

      # Forward and reverse secondary zones for neighboring teams in the ring.
      "psa-team8.cit.tum.de" = {
        master = false;
        masters = [(teamDns 8)];
        file = "psa-team8.cit.tum.de.zone";
      };

      "psa-team1.cit.tum.de" = {
        master = false;
        masters = [(teamDns 1)];
        file = "psa-team1.cit.tum.de.zone";
      };

      "8.168.192.in-addr.arpa" = {
        master = false;
        masters = [(teamDns 8)];
        file = "db.192.168.8";
      };

      "1.168.192.in-addr.arpa" = {
        master = false;
        masters = [(teamDns 1)];
        file = "db.192.168.1";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [53];
  networking.firewall.allowedUDPPorts = [53];
}
