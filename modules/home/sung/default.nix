{ ... }: {
  flake.homeModules.sung = { pkgs, ... }: {
    home.packages = [ (pkgs.callPackage ./_package.nix { }) ];
  };
}
