# VERT (github.com/VERT-sh/vert) -- WASM-based file converter, self-hosted
# as a single stateless container (client does the actual conversion work
# in-browser, so there's no compose stack/secrets/volumes to manage, unlike
# reactive-resume/wazuh). Loopback-only, same as the rest of this flake's
# self-hosted services.
{ self, inputs, ... }: {
  flake.nixosModules.vert = { ... }: {
    virtualisation.oci-containers.containers.vert = {
      image = "ghcr.io/vert-sh/vert:latest";
      autoStart = true;
      ports = [ "127.0.0.1:3030:80" ];
    };
  };
}
