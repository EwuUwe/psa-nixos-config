{
  lib,
  config,
  ...
}: {
  sops.secrets = {
    "hashed_passwords/xaver".neededForUsers = true;
    "hashed_passwords/basti".neededForUsers = true;
  };

  users.users =
    {
      "root" = {
        openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1bL8aC20ERDdJE2NqzIBvs8zXmCbFZ7fh5qXyqGNF7XfdfbsPBfQBSeJoncVfTJRFNYF4E+1Me918QMIpqa9XR4nJYOdOzff1JLYp1Z1X28Dx3//aOir8ziPCvGZShFDXoxLp6MNFIiEpI/IEW9OqxLhKj6YWVEDwK1ons7+pXnPM6Nd9lPd2UeqWWRpuuf9sa2AimQ1ZBJlnp7xHFTxvxdWMkTu6aH0j+aTT1w1+UDN2laS4nsmAJOO2KjeZq6xpbdmj9cjuxBJtM3Dsoq4ZJGdzez7XYhvCTQoQFl/5G0+4FBZeAgL/4ov12flGijZIIaXvmMBkLZRYg3E2m1Rp Praktikum Systemadministration"];
      };
    }
    // builtins.listToAttrs (lib.imap0 (i: v: let
        name = "u_" + (builtins.elemAt (builtins.split " " v.name) 0 |> builtins.substring 0 1 |> lib.strings.toLower) + (builtins.elemAt (builtins.split " " v.name) 2 |> builtins.substring 0 5 |> lib.strings.toLower);
      in {
        inherit name;
        value =
          {
            isNormalUser = true;
            uid = 10000 + i;
            openssh.authorizedKeys.keys = v.sshKeys or [];
          }
          // lib.optionalAttrs (v ? group) {
            inherit (v) group;
          }
          // lib.optionalAttrs (v ? hashedPasswordFile) {
            inherit (v) hashedPasswordFile;
          };
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
        {name = "Leopold Cario";}
        {name = "Michael Jurcenko";}
        {name = "Hosan Lee";}
        {name = "Carol Stefan";}
        {name = "Amine haddad";}
        {name = "Ahmed Amine Loukil";}
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
        {name = "Michael Ertl";}
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
