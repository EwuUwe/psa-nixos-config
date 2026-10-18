_: {
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "vmpsateam09-02";

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/6f2bceb5-7e60-4aa3-8235-b6ad5c20032c";
    fsType = "ext4";
  };

  system.stateVersion = "26.11";
}
