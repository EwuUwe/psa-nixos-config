{lib, ...}: {
  networking.interfaces.enp0s8 = {
    useDHCP = false;
    ipv4 = {
      addresses = [
        {
          address = "192.168.9.2";
          prefixLength = 24;
        }
      ];
      # Reach each team's LAN and its transit subnet through VM 01.
      routes =
        lib.range 1 8
        |> lib.concatMap (team:
          map (address: {
            inherit address;
            prefixLength = 24;
            via = "192.168.9.1";
          }) [
            "192.168.${toString team}.0"
            "192.168.9${toString team}.0"
          ]);
    };
  };
}
