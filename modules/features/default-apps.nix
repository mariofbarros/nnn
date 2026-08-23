{ self, inputs, ... }: {
  flake.nixosModules.defaultApps = { pkgs, ... }: {
    # Covers CLI tools/scripts that respect $BROWSER -- the mimeapps.list
    # side is handled by home-manager (see modules/home/xdg.nix).
    environment.sessionVariables.BROWSER = "librewolf";
  };
}
