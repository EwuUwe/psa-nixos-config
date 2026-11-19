{
  config,
  lib,
  pkgs,
  ...
}: let
  postgres = pkgs.postgresql_18;
  secret = name: config.sops.placeholder."database/${name}";
  adminPassfile = config.sops.templates."psa-admin.pgpass".path;
  backup = pkgs.writeShellApplication {
    name = "backup_PSA_05.sh";
    runtimeInputs = [postgres pkgs.coreutils pkgs.findutils];
    text = builtins.readFile ../scripts/backup_PSA_05.sh;
  };
in {
  sops.secrets =
    {
      "database/remote" = {};
    }
    // lib.genAttrs ["database/admin" "database/local" "database/reader"] (_: {
      sopsFile = ../secrets.yaml;
      owner = "postgres";
    });
  sops.templates = {
    "psa-admin.pgpass" = {
      owner = "postgres";
      content = "127.0.0.1:5432:*:postgres:${secret "admin"}\n";
    };
    "psa-local.pgpass".content = ''
      127.0.0.1:5432:*:postgres:${secret "admin"}
      127.0.0.1:5432:*:psa_local:${secret "local"}
      127.0.0.1:5432:*:psa_reader:${secret "reader"}
    '';
    "psa-database.sql" = {
      owner = "postgres";
      content = ''
        \set ON_ERROR_STOP on
        CREATE ROLE psa_local LOGIN PASSWORD '${secret "local"}';
        CREATE ROLE psa_remote LOGIN PASSWORD '${secret "remote"}';
        CREATE ROLE psa_reader LOGIN PASSWORD '${secret "reader"}' BYPASSRLS;
        GRANT pg_read_all_data TO psa_reader;
        CREATE DATABASE psa_local OWNER psa_local;
        CREATE DATABASE psa_remote OWNER psa_remote;
        REVOKE TEMPORARY ON DATABASE postgres, template1, psa_local, psa_remote FROM PUBLIC;
        GRANT TEMPORARY ON DATABASE psa_local TO psa_local;
        GRANT TEMPORARY ON DATABASE psa_remote TO psa_remote;
      '';
    };
  };

  services.postgresql = {
    enable = true;
    package = postgres;
    enableTCPIP = true;
    initialScript = config.sops.templates."psa-database.sql".path;
    settings.password_encryption = "scram-sha-256";
    initdbArgs = ["--pwfile=${config.sops.secrets."database/admin".path}"];
    authentication = lib.mkForce ''
      local psa_local psa_local scram-sha-256
      local all psa_reader,postgres scram-sha-256
      host psa_local psa_local 127.0.0.1/32 scram-sha-256
      host psa_local psa_local ::1/128 scram-sha-256
      host all psa_reader,postgres 127.0.0.1/32 scram-sha-256
      host all psa_reader,postgres ::1/128 scram-sha-256
      host psa_remote psa_remote 192.168.9.1/32 scram-sha-256
      host replication postgres 127.0.0.1/32 scram-sha-256
      local all all reject
      host all all all reject
    '';
  };
  systemd.services.postgresql-setup.environment = {
    PGHOST = "127.0.0.1";
    PGPASSFILE = adminPassfile;
  };
  networking.firewall.extraInputRules = ''
    ip saddr 192.168.9.1 ip daddr 192.168.9.2 tcp dport 5432 accept
  '';
  systemd.tmpfiles.rules = ["d /var/backup/postgresql 0700 postgres postgres -"];

  systemd.services.postgres-backup = {
    startAt = "*-*-* 03:00:00";
    requires = ["postgresql.target"];
    after = ["postgresql.target"];
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      ExecStart = "${backup}/bin/backup_PSA_05.sh";
    };
  };
}
