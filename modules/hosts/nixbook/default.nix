{ self, inputs, ... }:

{
  flake.nixosConfigurations.nixbook = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.nixbookConfiguration
    ];
  };
}
