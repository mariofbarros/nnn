{ self, inputs, ... }:

{
  flake.nixosConfigurations.nix-btw = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.myMachineConfiguration
    ];
  };
}