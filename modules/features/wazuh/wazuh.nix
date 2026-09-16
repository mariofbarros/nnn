# Wazuh (github.com/wazuh/wazuh), self-hosted single-node deployment --
# manager + indexer (OpenSearch-based) + dashboard, run exactly as upstream
# ships it (wazuh/wazuh-docker, single-node/), since it's a certificate-
# bootstrapped multi-container stack that isn't a good fit for hand-rolled
# oci-containers. See ./docker-compose.yml for what was changed from
# upstream (loopback-only port bindings).
#
# This is a full SIEM stack (OpenSearch under the hood) -- expect several
# GB of RAM in steady state, heavier on a laptop battery than the rest of
# this flake's services.
{ self, inputs, ... }: {
  flake.nixosModules.wazuh = { pkgs, ... }: {
    # wazuh.indexer (OpenSearch-based) needs vm.max_map_count >= 262144;
    # modules/features/gaming.nix already sets it far higher for
    # DXVK/VKD3D-proton, which comfortably covers this too.

    systemd.services.wazuh-setup = {
      description = "Wazuh: sync compose files + generate indexer TLS certs";
      wantedBy = [ "multi-user.target" ];
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      before = [ "wazuh.service" ];

      serviceConfig.Type = "oneshot";

      script = ''
        set -euo pipefail
        install -d -m 0755 /var/lib/wazuh/config/wazuh_cluster
        install -d -m 0755 /var/lib/wazuh/config/wazuh_dashboard
        install -d -m 0755 /var/lib/wazuh/config/wazuh_indexer

        install -m 0644 ${./docker-compose.yml} /var/lib/wazuh/docker-compose.yml
        install -m 0644 ${./generate-indexer-certs.yml} /var/lib/wazuh/generate-indexer-certs.yml
        install -m 0644 ${./config/certs.yml} /var/lib/wazuh/config/certs.yml
        install -m 0644 ${./config/wazuh_cluster/wazuh_manager.conf} /var/lib/wazuh/config/wazuh_cluster/wazuh_manager.conf
        install -m 0644 ${./config/wazuh_dashboard/opensearch_dashboards.yml} /var/lib/wazuh/config/wazuh_dashboard/opensearch_dashboards.yml
        install -m 0644 ${./config/wazuh_dashboard/wazuh.yml} /var/lib/wazuh/config/wazuh_dashboard/wazuh.yml
        install -m 0644 ${./config/wazuh_indexer/internal_users.yml} /var/lib/wazuh/config/wazuh_indexer/internal_users.yml
        install -m 0644 ${./config/wazuh_indexer/wazuh.indexer.yml} /var/lib/wazuh/config/wazuh_indexer/wazuh.indexer.yml

        cd /var/lib/wazuh
        if [ ! -d config/wazuh_indexer_ssl_certs ]; then
          ${pkgs.docker-compose}/bin/docker-compose -f generate-indexer-certs.yml run --rm generator
        fi
      '';
    };

    systemd.services.wazuh = {
      description = "Wazuh (docker compose)";
      after = [ "docker.service" "wazuh-setup.service" "network-online.target" ];
      requires = [ "docker.service" "wazuh-setup.service" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        WorkingDirectory = "/var/lib/wazuh";
        ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d --remove-orphans";
        ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
      };
    };
  };
}
