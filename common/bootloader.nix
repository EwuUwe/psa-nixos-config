_: {
  boot = {
    tmp.useTmpfs = true;
    loader = {
      grub.enable = true;
      grub.device = "/dev/sda";
    };
    supportedFilesystems = ["ext4" "ntfs"];
  };
}
