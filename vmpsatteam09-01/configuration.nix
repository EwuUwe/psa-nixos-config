_: {
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "vmpsateam09-02";

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/0cdf521e-8c02-4d3d-8bc0-ebf992401b22";
    fsType = "ext4";
  };

  system.stateVersion = "26.11";
}
