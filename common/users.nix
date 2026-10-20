{
  lib,
  config,
  ...
}: {
  sops.secrets = {
    "hashed_passwords/xaver".neededForUsers = true;
    "hashed_passwords/basti".neededForUsers = true;
  };

  users.mutableUsers = false;
  users.users =
    {
      "root" = {
        openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1bL8aC20ERDdJE2NqzIBvs8zXmCbFZ7fh5qXyqGNF7XfdfbsPBfQBSeJoncVfTJRFNYF4E+1Me918QMIpqa9XR4nJYOdOzff1JLYp1Z1X28Dx3//aOir8ziPCvGZShFDXoxLp6MNFIiEpI/IEW9OqxLhKj6YWVEDwK1ons7+pXnPM6Nd9lPd2UeqWWRpuuf9sa2AimQ1ZBJlnp7xHFTxvxdWMkTu6aH0j+aTT1w1+UDN2laS4nsmAJOO2KjeZq6xpbdmj9cjuxBJtM3Dsoq4ZJGdzez7XYhvCTQoQFl/5G0+4FBZeAgL/4ov12flGijZIIaXvmMBkLZRYg3E2m1Rp Praktikum Systemadministration"];
      };
    }
    # Map list of people into user attributes and merge them with root.
    // builtins.listToAttrs (lib.imap0 (i: v: let
        # First initial plus up to five letters of the second name.
        name = let
          parts = lib.strings.splitString " " (lib.strings.toLower v.name);
        in "u_${builtins.substring 0 1 (builtins.elemAt parts 0)}${builtins.substring 0 5 (builtins.elemAt parts 1)}";
      in {
        inherit name;
        value =
          {
            isNormalUser = true;
            uid = 10000 + i;
            openssh.authorizedKeys.keys = v.sshKeys;
          }
          # Optional fields, copy only when they exist in the entry
          // (builtins.intersectAttrs {
              group = null;
              hashedPasswordFile = null;
            }
            v);
      }) [
        {
          name = "Malte Verhoeff";
          sshKeys = ["AAAAC3NzaC1lZDI1NTE5AAAAIIgTXg1vlQHqmXrLMMTaBQDOX1fsSZIRQ2bSkFSvwePF go76dep@psa.in.tum.de"];
        }
        {
          name = "Robert Zeitter";
          sshKeys = ["AAAAC3NzaC1lZDI1NTE5AAAAIIFL7wTyasJrntnwrFomWbMUf8Jm/66RWlKa5ysZkDLW"];
        }
        {
          name = "Helen Krebs";
          sshKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFKygI5jH8V35uxaT/uRcEBJN2coyzDbf8awrVUegUU5 helenkrebs@MacBook-Air-von-Helen.local"];
        }
        {
          name = "Jonas Reinstaedtler";
          sshKeys = ["AAAAC3NzaC1lZDI1NTE5AAAAIH4lohQS8EWFcPnz8JA9EfFhXEYwH/3ucDyEH6OnkrC0 jonas@nixos-desktop"];
        }
        {
          name = "Leopold Cario";
          sshKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEDObAEdrNpVH9D5acVJdg2lSknsM09ffeKqqsQhW4Ox"];
        }
        {
          name = "Michael Jurcenko";
          sshKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF/yYMD3bsYlHGRgevu3oyT/JZyPSSsfUTftZKnAVQm6 go98tuz@tum.de"];
        }
        {
          name = "Hosan Lee";
          sshKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPRd9V/RzJw6FRdgZvU4KDDJEuN2rKpNVSFs4q/1BfbA ge85teg@mytum.de"];
        }
        {
          name = "Carol Stefan";
          sshKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID9Hlv5Xm4QZ+RU0bJ3PmbSw5GK5zEaDOoq9GURe98ty carol@carol-Latitude-5480"];
        }
        {
          name = "Amine haddad";
          sshKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBCvWXrVekRVDCQHLVjSEI4GQfehNuee8DNA8yizwmr/ aminehaddad@MBAIR-102678948888.local"];
        }
        {
          name = "Ahmed Amine Loukil";
          sshKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAVstioMk/GT/vogMIiQeYXLVSw2mX4shA8xQDQzopd7 u_aamine-psa"];
        }
        {
          name = "Julius Rehbein";
          sshKeys = ["AAAAC3NzaC1lZDI1NTE5AAAAIDFBR5pK2IItwn2t/3KZugbcBchSpbyMBIfMb0Mi5cuL julius.rehbein@tum.de"];
        }
        {
          name = "Tim Adamczewski";
          sshKeys = ["AAAAC3NzaC1lZDI1NTE5AAAAIFPIf5z68ATsbOn9kEPuBTAeL+3oKZjmLB2mFLY/Hmwh tim@tim-17Z90Q-G-AA78G"];
        }
        {
          name = "Richard Magula";
          sshKeys = ["AAAAC3NzaC1lZDI1NTE5AAAAIBaeqU5at9QgIAhBxlXZjBhvSg9WdKbBao89r4NwqJvP richard@LAPTOP-DULOAERK"];
        }
        {
          name = "Michael Ertl";
          sshKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILPihIybh9XJQzjRqVq6BNJd8XQVwwnxmwsZBfMBfJYS go79bug@mytum.de"];
        }
        {
          name = "Luis Feulner";
          sshKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAhdVtg2TdDN7sjELDYOof3Dk7bTy4tLIrZJUioDYNnt"];
        }
        {
          name = "Tobias Stauber";
          sshKeys = ["AAAAC3NzaC1lZDI1NTE5AAAAIOaoX7FmojjjQk/AqolVsr20m/Uo9DiWQFnV1xD+CBXc"];
        }
        {
          name = "Bastian Reich";
          group = "wheel";
          hashedPasswordFile = config.sops.secrets."hashed_passwords/basti".path;
          sshKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJesDAbM93JVSKtYrk5b5MN/idRU2nIeD5WHDjwFpwGX bastian.reich@eposte.de"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOszEkR9pYaB+Dv6EG6T8rZZWaaeNOoV1k4IanNWwp0+ bastian.reich@eposte.de"
          ];
        }
        {
          name = "Xaver Oswald";
          group = "wheel";
          hashedPasswordFile = config.sops.secrets."hashed_passwords/xaver".path;
          sshKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMtVH4zdklVJpw2Czvu+bZAmvuwpuzh9dxok9P6oUU/J"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5N4yzSh0MIfUAU1whb3ptr00WAXEQtr+kKhiGHu7EN"
          ];
        }
      ]);
}
