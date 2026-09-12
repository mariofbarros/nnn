{ self, inputs, ... }: {
  flake.nixosModules.searxng = { pkgs, config, ... }: {
    services.searx = {
      enable = true;

      # Ships a Tokyo Night reskin on the desktop and an Everforest one on
      # the laptop (see ./searxng-tokyo-night.css / ./searxng-everforest.css),
      # appended to the compiled stylesheets -- same palette as kitty/niri on
      # each host, applied here via CSS custom-property overrides rather than
      # patching templates.
      package = pkgs.searxng.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          for f in $out/lib/python3.*/site-packages/searx/static/themes/simple/sxng-ltr.min.css \
                   $out/lib/python3.*/site-packages/searx/static/themes/simple/sxng-rtl.min.css; do
            cat ${if config.networking.hostName == "nixbook" then ./searxng-everforest.css else ./searxng-tokyo-night.css} >> "$f"
          done
        '';
      });

      redisCreateLocally = true;

      # Keeps the secret key out of the world-readable /nix/store: this
      # points at a plain file on disk (not built by Nix), read by systemd
      # at service start.
      environmentFile = "/var/lib/searxng/secret.env";

      settings = {
        general.debug = false;
        server = {

          bind_address = "127.0.0.1";
          port = 8888;
        };
        # Activates :root.theme-dark, the selector our appended CSS targets.
        ui.theme_args.simple_style = "dark";
      };
    };
  };
}
