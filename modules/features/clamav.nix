{ self, inputs, ... }: {
  flake.nixosModules.clamav = { pkgs, ... }: {
    services.clamav = {
      daemon.enable = true;
      updater.enable = true;

      # Weekly scan of the user's home directory; clamd (daemon.enable) still
      # provides on-demand scanning via `clamdscan` the rest of the time.
      scanner = {
        enable = true;
        interval = "weekly";
        scanDirectories = [ "/home" ];
      };
    };
  };
}
