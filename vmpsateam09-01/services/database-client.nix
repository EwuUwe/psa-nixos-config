{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = [pkgs.postgresql_18];
  sops.secrets."database/remote" = {};
  sops.templates."psa-remote.pgpass" = {
    mode = "0600";
    content = "192.168.9.2:5432:*:psa_remote:${config.sops.placeholder."database/remote"}\n";
  };
}
