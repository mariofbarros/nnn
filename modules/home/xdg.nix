{ self, inputs, ... }: {
  flake.homeModules.xdg = { pkgs, ... }: {
    # Writes ~/.config/mimeapps.list -- the file xdg-open/xdg-mime read to
    # decide which app opens links and .html files. This replaces the old
    # system.activationScripts.defaultBrowser. $BROWSER stays system-side in
    # default-apps.nix for CLI tools that respect it.
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "librewolf.desktop";
        "x-scheme-handler/http" = "librewolf.desktop";
        "x-scheme-handler/https" = "librewolf.desktop";
        "x-scheme-handler/about" = "librewolf.desktop";
        "x-scheme-handler/unknown" = "librewolf.desktop";
      };
    };
  };
}
