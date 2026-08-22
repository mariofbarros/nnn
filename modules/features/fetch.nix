{ self, inputs, ... }: {
  flake.nixosModules.fetch = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.fetch ];

    programs.fish.shellAbbrs.fetch = "command fetch -l NixOS";
  };
}
