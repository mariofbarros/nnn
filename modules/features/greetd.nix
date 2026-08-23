{ self, inputs, ... }: {
  flake.nixosModules.greetd = { config, pkgs, lib, ... }: {
    # greetd replaces xserver's implicit LightDM fallback as the display
    # manager; both would otherwise fight over the display-manager.service
    # systemd alias.
    services.xserver.displayManager.lightdm.enable = false;

    services.greetd = {
      enable = true;
      useTextGreeter = true;

      settings.default_session.command =
        let
          # Tokyo Night, from the shared lib/palette.nix palette -- same accent
          # blue as the terminal border and window focus ring, same muted
          # violet-gray as secondary text, same teal reserved for a distinct
          # interactive value (kitty's url_color; here, typed input).
          colors = import ../../lib/palette.nix;
          theme = lib.concatStringsSep ";" [
            "border=${colors.accent}"
            "container=${colors.bg1}"
            "text=${colors.fg}"
            "prompt=${colors.accent}"
            "input=${colors.teal}"
            "action=${colors.fgMuted}"
            "button=${colors.accent}"
          ];
        in
        lib.concatStringsSep " " [
          (lib.getExe pkgs.tuigreet)
          "--time"
          "--remember"
          "--remember-session"
          "--asterisks"
          # NOT /run/current-system/sw/share/wayland-sessions -- that
          # directory is never populated (environment.pathsToLink's
          # default whitelist excludes share/wayland-sessions). Session
          # desktop files registered via services.displayManager
          # .sessionPackages (by programs.niri, among others) instead land
          # in this dedicated derivation, normally exposed to apps only
          # via XDG_DATA_DIRS.
          "--sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"
          "--greeting nix-btw"
          "--theme ${theme}"
        ];
    };
  };
}
