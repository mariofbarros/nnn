{ self, inputs, ... }: {
  flake.homeModules.theming = { pkgs, ... }: {
    # gsettings-backed theme: reaches GTK4/libadwaita, which the system-side
    # GTK_THEME env var can't. Packages stay in the system theming module.
    gtk = {
      enable = true;
      theme = { name = "adw-gtk3-dark"; package = pkgs.adw-gtk3; };
      iconTheme = { name = "Papirus"; package = pkgs.papirus-icon-theme; };
      gtk3.extraConfig = { gtk-application-prefer-dark-theme = 1; };
      gtk4.extraConfig = { gtk-application-prefer-dark-theme = 1; };
    };

    qt = {
      enable = true;
      platformTheme.name = "qt6ct";
    };
  };
}
