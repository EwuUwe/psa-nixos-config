#!/usr/bin/env bash
set -uo pipefail
export LC_ALL=C

passed=0
failed=0

# Remote transit gateways from VM 01's configured routes.
remote_peers=(
  192.168.91.2 192.168.92.2 192.168.93.2 192.168.94.2
  192.168.95.2 192.168.96.2 192.168.97.2 192.168.98.2
)

section() {
  printf '\n========== %s ==========\n' "$1"
}

command_line() {
  printf '  $'
  printf ' %q' "$@"
  printf '\n'
}

run() {
  command_line "$@"
  "$@"
}

check() {
  local title=$1 status
  shift
  printf '\n--- %s ---\n' "$title"
  if "$@"; then
    echo 'PASS'
    passed=$((passed + 1))
  else
    status=$?
    printf 'FAIL (exit %d)\n' "$status"
    failed=$((failed + 1))
  fi
}

show() {
  local title=$1 status
  shift
  printf '\n--- %s ---\n' "$title"
  run "$@" || {
    status=$?
    printf 'FAIL (exit %d)\n' "$status"
    failed=$((failed + 1))
  }
}

dns_query() {
  local answer status
  local -a command=(dig +time=3 +tries=1 +noall +comments +answer "$@" example.org A)
  command_line "${command[@]}"
  answer=$("${command[@]}" 2>&1)
  status=$?
  printf '%s\n' "$answer"
  if ((status != 0)); then
    echo "DNS request failed (dig exit $status)."
    return 1
  fi
  if [[ $answer != *'status: NOERROR'* ]]; then
    echo 'Expected DNS status NOERROR.'
    return 1
  fi
  if ! grep -Eq '[[:space:]]IN[[:space:]]+A[[:space:]]+[0-9.]+' <<< "$answer"; then
    echo 'No IPv4 A record returned for example.org.'
    return 1
  fi
}

proxy_settings() {
  local variable actual errors=0
  for variable in http_proxy https_proxy; do
    command_line printenv "$variable"
    actual=$(printenv "$variable")
    printf '%s=%s\n' "$variable" "${actual:-<unset>}"
    if [[ $actual != http://proxy.cit.tum.de:8080 ]]; then
      echo "Expected $variable=http://proxy.cit.tum.de:8080"
      errors=$((errors + 1))
    fi
  done
  ((errors == 0))
}

reject_count() {
  nft list chain inet assignment output | awk '/counter packets .* reject/ {print $3}'
}

blocked_external_tcp() {
  local before after status
  before=$(reject_count) || return 1
  if [[ ! $before =~ ^[0-9]+$ ]]; then
    echo 'Outgoing reject counter not found.'
    return 1
  fi
  run timeout 5 bash -c 'exec 3<>/dev/tcp/1.1.1.1/443'
  status=$?
  after=$(reject_count) || return 1
  printf 'Rejected packets: %s -> %s\n' "$before" "${after:-<missing>}"
  if ((status == 0)); then
    echo 'Expected rejection, but the connection succeeded.'
    return 1
  fi
  if ((status == 124)); then
    echo 'Timed out instead of being rejected locally.'
    return 1
  fi
  if [[ ! $after =~ ^[0-9]+$ ]] || ((after <= before)); then
    echo 'Connection failed, but the local reject counter did not increase.'
    return 1
  fi
}

if ((EUID != 0)); then
  echo 'Run: sudo -i bash /root/test_PSA_02.sh' >&2
  exit 2
fi
case $(hostname -s) in
  vmpsateam09-01) sibling=192.168.9.2 ;;
  vmpsateam09-02) sibling=192.168.9.1 ;;
  *) echo 'Expected a team 09 VM.' >&2; exit 2 ;;
esac

section '1. Network configuration'
show 'Addresses' ip -brief address
show 'Routes' ip -4 route show
show 'Persistent adapter configuration' cat /etc/systemd/network/40-enp0s8.network
check "Team connectivity: $sibling replies to ping" \
  run ping -n -c 2 -W 2 "$sibling"
for peer in "${remote_peers[@]}"; do
  check "Inter-team connectivity: $peer replies to ping" \
    run ping -n -c 2 -W 2 -- "$peer"
done

section '2.1 Firewall: incoming TCP connections'
show 'Incoming policy: drop unsolicited traffic, accept established replies' \
  nft list chain inet nixos-fw input
show 'Incoming exceptions: TCP 22/80/443 and ICMP' \
  nft list chain inet nixos-fw input-allow
show "Peer $sibling: expect 22 open, 80/443 open or closed, 44444 filtered" \
  nmap -n -Pn -sS --reason --max-retries 1 --host-timeout 30s -p 22,80,443,44444 "$sibling"
show 'Stateless HTTP(S): incoming ports 80/443 use notrack' \
  nft list chain inet assignment prerouting_raw
show 'Stateless HTTP(S): replies from ports 80/443 use notrack' \
  nft list chain inet assignment output_raw

section '2.2 Firewall: outgoing connections, DNS and web browsing'
show 'Unrestricted destinations: FMI, teams 1-9, transit subnets 91-98' \
  nft list set inet assignment allowed_networks
show 'Outgoing policy and exceptions' \
  nft list chain inet assignment output
check 'Direct HTTPS to 1.1.1.1:443 is rejected locally' \
  blocked_external_tcp
check 'System DNS returns an IPv4 address for example.org' dns_query
check 'DNS via FMI/UDP returns an IPv4 address for example.org' dns_query @131.159.254.1 +notcp +ignore
check 'HTTP and HTTPS use proxy.cit.tum.de:8080' proxy_settings
show 'Networks that bypass the proxy' printenv no_proxy
check 'HTTPS browsing through the proxy succeeds' \
  run curl --fail --silent --show-error --connect-timeout 5 --max-time 15 --output /dev/null \
    --write-out 'HTTP status: %{http_code}\nRemote endpoint: %{remote_ip}:%{remote_port}\nDownloaded: %{size_download} bytes\n' \
    https://example.org/

section '2.3 Firewall: ICMP'
check 'External ICMP: 1.1.1.1 replies to ping' \
  run ping -n -c 2 -W 2 1.1.1.1
printf '\nResults: %d passed, %d failed\n' "$passed" "$failed"
((failed == 0))
