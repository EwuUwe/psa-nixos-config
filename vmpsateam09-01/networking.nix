{lib, ...}: {
  networking = {
    nameservers = [
      "127.0.0.1"
    ];
    search = [
      "psa-team9.cit.tum.de"
    ];

    interfaces.enp0s8 = {
      useDHCP = false;
      ipv4 = {
        addresses =
          [
            {
              address = "192.168.9.1";
              prefixLength = 24;
            }
          ]
          ++ (lib.range 1 8
            |> map toString
            |> map (i: {
              address = "192.168.9${i}.1";
              prefixLength = 24;
            }));
        # Reach each remote team's LAN through its transit subnet.
        routes =
          lib.range 1 8
          |> map toString
          |> map (i: {
            address = "192.168.${i}.0";
            prefixLength = 24;
            via = "192.168.9${i}.2";
          });
      };
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv4.conf.default.send_redirects" = false;
    "net.ipv4.conf.enp0s3.send_redirects" = false;
    "net.ipv4.conf.enp0s8.send_redirects" = false;
  };
}
