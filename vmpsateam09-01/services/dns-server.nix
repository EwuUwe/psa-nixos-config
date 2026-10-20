{lib, ...}: let
  # Forward zones for other teams (teams 2 to 7)
  teamForwardZones = lib.concatMapStrings (i: ''
    zone "psa-team${toString i}.cit.tum.de" {
      type forward;
      forward only;
      forwarders { 192.168.${toString i}.1; 192.168.9${toString i}.2; };
    };
    zone "${toString i}.168.192.in-addr.arpa" {
      type forward;
      forward only;
      forwarders { 192.168.${toString i}.1; 192.168.9${toString i}.2; };
    };
  '') (lib.range 2 7);

  # Reverse lookup forwarding for Team 8 and Team 1
  team8ForwardZone = ''
    zone "8.168.192.in-addr.arpa" {
      type forward;
      forward only;
      forwarders { 192.168.8.11; 192.168.8.1; 192.168.98.2; };
    };
  '';

  team1ForwardZone = ''
    zone "1.168.192.in-addr.arpa" {
      type forward;
      forward only;
      forwarders { 192.168.1.1; 192.168.91.2; };
    };
  '';

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
        192.168.8.11;
        192.168.8.1;
        192.168.98.2;
        192.168.1.1;
        192.168.91.2;
      };
    '';

    extraConfig = teamForwardZones + team8ForwardZone + team1ForwardZone;

    zones = {
      "psa-team9.cit.tum.de" = masterZone ./zones/psa-team9.cit.tum.de.zone;
      "9.168.192.in-addr.arpa" = masterZone ./zones/db.192.168.9;

      # Secondary (slave) zones for neighboring teams in the ring (Team 8 and Team 1)
      "psa-team8.cit.tum.de" = {
        master = false;
        masters = [
          "192.168.8.11"
          "192.168.8.1"
          "192.168.98.2"
        ];
        file = "psa-team8.cit.tum.de.zone";
      };

      "psa-team1.cit.tum.de" = {
        master = false;
        masters = [
          "192.168.1.1"
          "192.168.91.2"
        ];
        file = "psa-team1.cit.tum.de.zone";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [53];
  networking.firewall.allowedUDPPorts = [53];
}
