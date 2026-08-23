{ self, inputs, ... }: {
  flake.nixosModules.theming = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      adw-gtk3           # clean dark GTK3/4-compatible theme
      papirus-icon-theme
      kdePackages.qt6ct  # lets Qt apps (Dolphin, OBS, VLC) follow a dark palette
    ];

    # QT_QPA_PLATFORMTHEME is set by home-manager's qt module instead (see
    # modules/home/theming.nix), which already sets it from platformTheme.name.
  };
}
