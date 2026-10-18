{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/26.05";

  outputs = {nixpkgs, ...}: let
    systems = [
      "x86_64-linux"
    ];

    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    nixosConfigurations = {
      vmpsateam09-01 = nixpkgs.lib.nixosSystem {
        modules = [
          ./vmpsateam09-01/configuration.nix
          ./common
        ];
      };
      vmpsateam09-02 = nixpkgs.lib.nixosSystem {
        modules = [./vmpsateam09-02/configuration.nix ./common];
      };
    };

    formatter = forAllSystems (
      system:
        nixpkgs.legacyPackages.${system}.alejandra
    );
  };
}
