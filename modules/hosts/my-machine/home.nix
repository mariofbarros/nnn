{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.homeManager = {
    pkgs,
    lib,
    ...
  }: {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];

    # Build home packages from the same nixpkgs as the system (no skew).
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    # Consumed by the nx fish CLI (modules/home/nx/) to operate on the real
    # checkout rather than its Nix store copy, and to target the right
    # nixosConfigurations output.
    home-manager.extraSpecialArgs = {
      repoDir = "/home/mario/nnn";
      hostName = "nix-btw";
    };

    home-manager.users.mario = {
      imports = [self.homeModules.default];
    };
  };
}
