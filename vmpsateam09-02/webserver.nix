{
  config,
  lib,
  pkgs,
  ...
}: let
  domain = "psa-team9.cit.tum.de";
  mainHost = "vmpsateam09-02.${domain}";
  users = lib.filterAttrs (_: user: user.isNormalUser) config.users.users;
  nginx = config.services.nginx;

  site = ip: root: {
    addSSL = true;
    listen = [
      {
        addr = ip;
        port = 80;
      }
      {
        addr = ip;
        port = 443;
        ssl = true;
      }
    ];
    sslCertificate = "/var/lib/psa-web/server.crt";
    sslCertificateKey = "/var/lib/psa-web/server.key";
    inherit root;
  };

  userLocations = lib.foldlAttrs (locations: name: user:
    locations
    // {
      "= /~${name}".return = "301 /~${name}/";
      "/~${name}/".alias = "${user.home}/.html-data/";
      "^~ /~${name}/cgi-bin/" = {
        alias = "${user.home}/.cgi-bin/";
        extraConfig = ''
          include ${pkgs.nginx}/conf/fastcgi_params;
          fastcgi_param SCRIPT_FILENAME $request_filename;
          fastcgi_pass unix:/run/fcgiwrap-${name}.sock;
        '';
      };
    }) {}
  users;

  rotation = {
    frequency = "daily";
    ifempty = true;
    missingok = true;
    compress = true;
    su = "${nginx.user} ${nginx.group}";
    postrotate = ''
      ${pkgs.systemd}/bin/systemctl kill --kill-whom=main --signal=USR1 nginx.service || true
    '';
  };
in {
  services.nginx = {
    enable = true;
    logError = "/var/log/nginx/error.log warn";
    commonHttpConfig = ''
      log_format privacy '[$time_local] "$request_method $uri $server_protocol" $status $body_bytes_sent';
      access_log /var/log/nginx/access.log privacy;
    '';
    virtualHosts = {
      "${mainHost}" =
        (site "192.168.9.2" ./websites/main)
        // {
          default = true;
          locations = userLocations;
        };
      "web2.${domain}" = site "192.168.9.2" ./websites/web2;
      "web3.${domain}" =
        (site "192.168.9.3" ./websites/web3)
        // {
          default = true;
        };
    };
  };

  services.fcgiwrap.instances =
    lib.mapAttrs (name: user: {
      process = {
        user = name;
        group = user.group;
      };
      socket = {
        address = "/run/fcgiwrap-${name}.sock";
        user = nginx.user;
        group = nginx.group;
        mode = "0600";
      };
    })
    users;

  systemd.tmpfiles.rules = lib.concatLists (lib.mapAttrsToList (name: user: [
      "a+ ${user.home} - - - - u:${nginx.user}:--x"
      "d ${user.home}/.html-data 0755 ${name} ${user.group} -"
      "d ${user.home}/.cgi-bin 0700 ${name} ${user.group} -"
    ])
    users);

  systemd.services.nginx = {
    requires = ["psa-web-certificate.service"];
    wants = ["network-online.target"];
    after = ["psa-web-certificate.service" "network-online.target"];
    serviceConfig.ProtectHome = lib.mkForce "read-only";
  };

  # Generate the private key on the VM, outside the world-readable Nix store.
  systemd.services.psa-web-certificate = {
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StateDirectory = "psa-web";
      StateDirectoryMode = "0750";
      Group = nginx.group;
      UMask = "0027";
    };
    script = ''
      if [ ! -s /var/lib/psa-web/server.key ] || \
         ! ${pkgs.openssl}/bin/openssl x509 -in /var/lib/psa-web/server.crt -noout -checkhost ${mainHost} >/dev/null 2>&1 || \
         ! ${pkgs.openssl}/bin/openssl x509 -in /var/lib/psa-web/server.crt -noout -checkhost web2.${domain} >/dev/null 2>&1; then
        ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:2048 -nodes -days 365 \
          -subj '/CN=${mainHost}' \
          -addext 'subjectAltName=DNS:${mainHost},DNS:web2.${domain},DNS:web3.${domain},IP:192.168.9.2,IP:192.168.9.3' \
          -keyout /var/lib/psa-web/server.key -out /var/lib/psa-web/server.crt
        chmod 0640 /var/lib/psa-web/server.key
      fi
    '';
  };

  services.logrotate = {
    enable = true;
    settings = {
      nginx.enable = false;
      psa-access =
        rotation
        // {
          files = ["/var/log/nginx/access.log"];
          rotate = 5;
          maxage = 5;
        };
      psa-error =
        rotation
        // {
          files = ["/var/log/nginx/error.log"];
          rotate = 1;
          maxage = 1;
        };
    };
  };
  systemd.services.logrotate.startAt = lib.mkForce "daily";
}
