{pkgs, ...}: let
  testScript = pkgs.writeShellScript "test_PSA_02.sh" (builtins.readFile ./scripts/test_PSA_02.sh);
in {
  environment.systemPackages = with pkgs; [
    bind.dnsutils
    curl
    iproute2
    iputils
    nftables
    nmap
  ];

  systemd.tmpfiles.rules = [
    "L+ /root/test_PSA_02.sh - root root - ${testScript}"
  ];
}
