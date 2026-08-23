{ self, inputs, ... }: {
  flake.nixosModules.apps = { pkgs, ... }: {
    # Everything here is deliberately system-wide, not a per-user preference
    # (see modules/home/apps.nix for the rest): rescue/admin-shell tools
    # that should exist even outside mario's home-manager profile, plus
    # bibata-cursors, which XCURSOR_THEME needs system-wide since greetd's
    # login screen renders before any user session (and its home-manager
    # profile) exists.
    environment.systemPackages = with pkgs; [
      wget
      git
      which
      file
      curl
      nmap            # Port scanning/network discovery
      mtr             # Route tracing
      vim
      bibata-cursors
    ];
  };
}
