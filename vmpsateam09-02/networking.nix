_: {
  networking.interfaces.enp0s8 = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "192.168.9.2";
        prefixLength = 24;
      }
    ];
  };
}
