{ self, inputs, lib, ... }: {
  # Declare homeModules as a mergeable option. flake's freeform type is
  # unique/raw, so without this each file under modules/home/ defining its own
  # flake.homeModules.<name> would collide. lazyAttrsOf lets them merge.
  options.flake.homeModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
  };

  config.flake.homeModules.default = { pkgs, ... }: {
    imports = [
      self.homeModules.kitty
      self.homeModules.theming
      self.homeModules.fetch
      self.homeModules.xdg
    ];

    home.stateVersion = "26.05";
  };
}
