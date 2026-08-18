{ self, inputs, ... }: {
  flake.nixosModules.defaultApps = { pkgs, ... }: {
    # Covers CLI tools/scripts that respect $BROWSER -- separate mechanism
    # from mimeapps.list below, which is what actually controls xdg-open.
    environment.sessionVariables.BROWSER = "librewolf";

    # No home-manager, so this writes ~/.config/mimeapps.list directly --
    # the actual file xdg-open/xdg-mime read to decide which app opens
    # links and .html files. Overwritten on every rebuild: don't hand-edit
    # this file on the machine, edit here instead.
    system.activationScripts.defaultBrowser = let
      mimeappsFile = pkgs.writeText "mimeapps.list" ''
        [Default Applications]
        text/html=librewolf.desktop
        x-scheme-handler/http=librewolf.desktop
        x-scheme-handler/https=librewolf.desktop
        x-scheme-handler/about=librewolf.desktop
        x-scheme-handler/unknown=librewolf.desktop
      '';
    in ''
      install -Dm644 -o mario ${mimeappsFile} /home/mario/.config/mimeapps.list
    '';
  };
}
