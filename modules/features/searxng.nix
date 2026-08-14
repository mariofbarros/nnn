{ self, inputs, ... }: {
  flake.nixosModules.searxng = { pkgs, ... }: {
    services.searx = {
      enable = true;
      package = pkgs.searxng;

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
      };
    };
  };
}
