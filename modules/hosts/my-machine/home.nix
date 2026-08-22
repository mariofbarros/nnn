{ self, inputs, ... }: {
  flake.nixosModules.homeManager = { pkgs, lib, ... }: {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];

    # Build home packages from the same nixpkgs as the system (no skew).
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    home-manager.users.mario = {
      imports = [ self.homeModules.default ];
    };
  };
}
