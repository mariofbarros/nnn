{ self, inputs, ... }: {
  flake.nixosModules.theming = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      adw-gtk3           # clean dark GTK3/4-compatible theme
      papirus-icon-theme
      kdePackages.qt6ct  # lets Qt apps (Dolphin, OBS, VLC) follow a dark palette
    ];

    environment.sessionVariables = {
      QT_QPA_PLATFORMTHEME = "qt6ct";
    };
  };
}
