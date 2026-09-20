# Cockpit (cockpit-project.org) -- web GUI for managing what's actually
# running on this box: start/stop/restart/logs for every systemd unit
# (searx, clamav-daemon, homepage-dashboard, and the docker-compose-backed
# reactive-resume/wazuh/vert units all show up here, since they're all
# systemd units regardless of what's underneath), plus basic resource
# graphs. Deliberately not Coolify or similar -- this repo's flake is
# already the source of truth for what's deployed (`nx deploy`); Cockpit
# just gives a panel onto the live systemd/docker state instead of trying
# to own deployment itself.
{ self, inputs, ... }: {
  flake.nixosModules.cockpit = { config, ... }: {
    # openFirewall defaults to false -- loopback-only, same as the rest of
    # this flake's self-hosted services. https://localhost:9090 (self-signed
    # cert); mario's already in "wheel" on both hosts, which is what
    # Cockpit checks for admin-level actions (start/stop/restart units).
    services.cockpit.enable = true;

    # Cockpit's CSRF/Origin check only allows the module's own default
    # (https://localhost:<port>) unless told otherwise -- 127.0.0.1 gets
    # rejected with "received request from bad Origin" even though it's
    # the same box, which is what homepage.nix links to.
    services.cockpit.allowed-origins = [
      "https://127.0.0.1:${toString config.services.cockpit.port}"
    ];
  };
}
