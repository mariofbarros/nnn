{ self, inputs, ... }: {
  # Personal dashboard linking to the other self-hosted services in this
  # flake (SearXNG, Reactive Resume, Wazuh). Loopback-only by default
  # (openFirewall stays false) since this is a single-box personal stack,
  # not a LAN-wide homelab dashboard.
  flake.nixosModules.homepage = { pkgs, ... }: {
    services.homepage-dashboard = {
      enable = true;
      listenPort = 8082;
      allowedHosts = "localhost:8082,127.0.0.1:8082";

      bookmarks = [
        {
          "Self-hosted" = [
            { SearXNG = [{ abbr = "SX"; href = "http://127.0.0.1:8888"; }]; }
            { "Reactive Resume" = [{ abbr = "RR"; href = "http://127.0.0.1:3000"; }]; }
            { "Wazuh dashboard" = [{ abbr = "WZ"; href = "https://127.0.0.1:443"; }]; }
          ];
        }
      ];

      services = [
        {
          "Self-hosted" = [
            {
              SearXNG = {
                href = "http://127.0.0.1:8888";
                description = "Metasearch engine";
              };
            }
            {
              "Reactive Resume" = {
                href = "http://127.0.0.1:3000";
                description = "Resume builder";
              };
            }
            {
              "Wazuh dashboard" = {
                href = "https://127.0.0.1:443";
                description = "SIEM / security monitoring";
              };
            }
          ];
        }
      ];

      widgets = [
        { resources = { cpu = true; memory = true; disk = "/"; }; }
        { search = { provider = "duckduckgo"; target = "_blank"; }; }
      ];
    };
  };
}
