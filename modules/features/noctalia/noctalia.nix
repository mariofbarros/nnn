{ self, inputs, ... }: {
  perSystem = { pkgs, ... }: {
    # Desktop (my-machine) and laptop (nixbook) keep separate settings
    # files rather than one shared file with an override merged on top --
    # their bar layouts have diverged beyond just monitors/screenOverrides
    # (different widget sets), so a single base + patch no longer covered
    # the real difference between the two.
    packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      settings = builtins.fromJSON (builtins.readFile ./noctalia-desktop.json);
    };

    packages.myNoctaliaLaptop = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      settings = builtins.fromJSON (builtins.readFile ./noctalia-laptop.json);
    };
  };
}
