{
  description = "PassiveLemon NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    spicetify-nix.url = "github:the-argus/spicetify-nix";
    home-manager.url = "github:nix-community/home-manager";
    lemondots.url = "github:PassiveLemon/lemondots";
  };

  outputs = {self, nixpkgs, ...}: {
    nixosConfigurations.lemon-tree = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./hosts/lemon-tree ];
    };
  };
}

#  outputs = {self, nixpkgs, ...} @ inputs: let
#    system = "x86_64-linux";
#  in {
#    nixosConfigurations = import ./hosts inputs;
#    };
#  };
#}