{ self, inputs, ... }: {
  flake.nixosModules.fetch = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.fetch ];
  };
}
