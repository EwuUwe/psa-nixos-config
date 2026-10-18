_: {
  # Use networkd instead of the pile of shell scripts
  networking.useNetworkd = true;
  systemd.network.enable = true;
}
