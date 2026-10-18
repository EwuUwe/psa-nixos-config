{lib, ...}: {
  users.users =
    {
      "root" = {
        openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1bL8aC20ERDdJE2NqzIBvs8zXmCbFZ7fh5qXyqGNF7XfdfbsPBfQBSeJoncVfTJRFNYF4E+1Me918QMIpqa9XR4nJYOdOzff1JLYp1Z1X28Dx3//aOir8ziPCvGZShFDXoxLp6MNFIiEpI/IEW9OqxLhKj6YWVEDwK1ons7+pXnPM6Nd9lPd2UeqWWRpuuf9sa2AimQ1ZBJlnp7xHFTxvxdWMkTu6aH0j+aTT1w1+UDN2laS4nsmAJOO2KjeZq6xpbdmj9cjuxBJtM3Dsoq4ZJGdzez7XYhvCTQoQFl/5G0+4FBZeAgL/4ov12flGijZIIaXvmMBkLZRYg3E2m1Rp Praktikum Systemadministration"];
      };
    }
    // builtins.listToAttrs (lib.imap0 (i: v: let
        name = "u_" + (builtins.elemAt (builtins.split " " v.name) 2 |> builtins.substring 0 4 |> lib.strings.toLower);
      in {
        inherit name;
        value = {
          isNormalUser = true;
          uid = 10000 + i;
          openssh.authorizedKeys.keys = lib.optional (v ? sshKey) v.sshKey;
        };
      }) [
        {name = "Malte Verhoeff";}
        {name = "Robert Zeitter";}
        {name = "Helen Krebs";}
        {name = "Jonas Reinstaedtler";}
        {name = "Leopold Cario";}
        {name = "Michael Jurcenko";}
        {name = "Hosan Lee";}
        {name = "Carol Stefan";}
        {name = "Amine haddad";}
        {name = "Ahmed Amine Loukil";}
        {name = "Julius Rehbein";}
        {name = "Tim Adamczewski";}
        {name = "Richard Magula";}
        {name = "Michael Ertl";}
        {name = "Luis Feulner";}
        {name = "Tobias Stauber";}
        {name = "Bastian Reich";}
        {
          name = "Xaver Oswald";
          sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMtVH4zdklVJpw2Czvu+bZAmvuwpuzh9dxok9P6oUU/J";
        }
      ]);
}
