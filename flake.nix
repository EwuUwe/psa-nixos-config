{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/26.05";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {nixpkgs, ...} @ inputs: let
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
        specialArgs = {
          inherit inputs;
        };
      };
      vmpsateam09-02 = nixpkgs.lib.nixosSystem {
        modules = [
          ./vmpsateam09-02/configuration.nix
          ./common
        ];
        specialArgs = {
          inherit inputs;
        };
      };
    };

    formatter = forAllSystems (
      system:
        nixpkgs.legacyPackages.${system}.alejandra
    );
  };
}
