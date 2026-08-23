{ self, inputs, ... }: {
  flake.homeModules.fish = { pkgs, ... }: {
    programs.fish = {
      enable = true;

      shellAbbrs.fetch = "command fetch -l NixOS";

      functions = {
        nrs = {
          description = "nixos-rebuild switch, with a real check that it actually applied";
          body = ''
            if test "$XDG_SESSION_TYPE" = "wayland"
                echo "Note: running from inside the graphical session. If this rebuild touches" \
                     "users/shells/PAM, the display manager restart can disrupt activation" \
                     "partway through. Ctrl+Alt+F3 to a TTY first if that happens."
            end

            sudo nixos-rebuild switch --flake .#nix-btw
            or return 1

            set -l registered (readlink -f /nix/var/nix/profiles/system)
            set -l running (readlink -f /run/current-system)

            if test "$registered" = "$running"
                echo "Applied and running: "(basename $running)
            else
                echo "Registered as current, but not actually running yet:"
                echo "  registered: "(basename $registered)
                echo "  running:    "(basename $running)
                echo "Reboot to apply cleanly: sudo reboot"
            end
          '';
        };

        noctalia-export = {
          description = "Export current noctalia-shell settings to noctalia.json";
          body = ''
            # Must be run from the flake root (uses the relative ./modules path below).
            nix run .#myNoctalia -- ipc call state all > /tmp/noctalia-state.json
            and cp /tmp/noctalia-state.json ./modules/features/noctalia.json
            and echo "noctalia.json updated"
          '';
        };
      };
    };
  };
}
