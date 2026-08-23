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
          # Tokyo Night, reused verbatim from modules/home/kitty.nix and the
          # niri focus-ring color in modules/features/niri.nix -- same accent
          # blue as the terminal border and window focus ring, same muted
          # violet-gray as secondary text, same teal reserved for a distinct
          # interactive value (kitty's url_color; here, typed input).
          theme = lib.concatStringsSep ";" [
            "border=#7aa2f7"
            "container=#292e42"
            "text=#c0caf5"
            "prompt=#7aa2f7"
            "input=#73daca"
            "action=#545c7e"
            "button=#7aa2f7"
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
