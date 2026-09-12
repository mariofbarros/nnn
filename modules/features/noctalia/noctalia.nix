{ self, inputs, ... }: {
  perSystem = { pkgs, ... }: let
    baseSettings = builtins.fromJSON (builtins.readFile ./noctalia.json);
  in {
    packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      settings = baseSettings;
    };

    # Single-output variant for laptop hosts. noctalia.json's bar.monitors
    # and bar.screenOverrides pin the desktop's two real output names
    # (DP-3/HDMI-A-1) plus a distinct widget set for each -- neither output
    # exists on a one-screen machine, so the bar would never attach
    # anywhere. Clearing both falls back to noctalia's "every monitor it
    # sees" default (just the one panel on a laptop), using the base
    # `bar.widgets` layout, which already mirrors the desktop's primary
    # screen.
    packages.myNoctaliaLaptop = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      settings = baseSettings // {
        bar = baseSettings.bar // {
          monitors = [];
          screenOverrides = [];
        };
      };
    };
  };
}
