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
  '') (lib.range 1 8);

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

      # Secondary (slave) zones for neighboring teams in the ring (Team 8 and Team 1)
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
    };
  };

  networking.firewall.allowedTCPPorts = [53];
  networking.firewall.allowedUDPPorts = [53];
}
