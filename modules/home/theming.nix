{ self, inputs, ... }: {
  flake.homeModules.theming = { pkgs, ... }: {
    # gsettings-backed theme: reaches GTK4/libadwaita, which the system-side
    # GTK_THEME env var can't. Packages stay in the system theming module.
    gtk = {
      enable = true;
      theme = { name = "adw-gtk3-dark"; package = pkgs.adw-gtk3; };
      iconTheme = { name = "Papirus"; package = pkgs.papirus-icon-theme; };
      # niri's prefer-no-csd (modules/features/niri.nix) only *requests*
      # server-side decoration -- most libadwaita/GTK4 apps ignore that
      # negotiation entirely and always draw their own headerbar. Since
      # niri has no window chrome of its own to fall back to, blanking
      # gtk-decoration-layout is what actually removes the minimize/
      # maximize/close buttons (the headerbar itself still renders, just
      # without the button row); use niri's own binds to close/maximize.
      gtk3.extraConfig = { gtk-application-prefer-dark-theme = 1; gtk-decoration-layout = ""; };
      gtk4.extraConfig = { gtk-application-prefer-dark-theme = 1; gtk-decoration-layout = ""; };
    };

    qt = {
      enable = true;
      platformTheme.name = "qt6ct";
    };
  };
}
