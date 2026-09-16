# Reactive Resume (github.com/reactive-resume/reactive-resume), self-hosted
# via its own docker-compose stack (postgres + redis + seaweedfs + the app)
# -- there's no nixpkgs package for it, so this mirrors the upstream
# docker-compose.yml (trimmed in ./docker-compose.yml) rather than
# reinventing it as individual oci-containers.
{ self, inputs, ... }: {
  flake.nixosModules.reactiveResume = { pkgs, ... }: {
    systemd.services.reactive-resume-setup = {
      description = "Reactive Resume: sync compose file + generate secrets";
      wantedBy = [ "multi-user.target" ];
      before = [ "reactive-resume.service" ];

      serviceConfig.Type = "oneshot";

      script = ''
        set -euo pipefail
        install -d -m 0750 /var/lib/reactive-resume/data
        install -m 0644 ${./docker-compose.yml} /var/lib/reactive-resume/docker-compose.yml

        if [ ! -f /var/lib/reactive-resume/.env ]; then
          umask 077
          {
            printf 'APP_URL="http://localhost:3000"\n'
            printf 'DATABASE_URL="postgresql://postgres:postgres@postgres:5432/postgres"\n'
            printf 'AUTH_SECRET="%s"\n' "$(${pkgs.openssl}/bin/openssl rand -hex 32)"
            printf 'ENCRYPTION_SECRET="%s"\n' "$(${pkgs.openssl}/bin/openssl rand -hex 32)"
            printf 'S3_ACCESS_KEY_ID="seaweedfs"\n'
            printf 'S3_SECRET_ACCESS_KEY="seaweedfs"\n'
            printf 'S3_REGION="us-east-1"\n'
            printf 'S3_ENDPOINT="http://seaweedfs:8333"\n'
            printf 'S3_BUCKET="reactive-resume"\n'
            printf 'S3_FORCE_PATH_STYLE="true"\n'
            printf 'REDIS_URL="redis://redis:6379"\n'
          } > /var/lib/reactive-resume/.env
        fi
      '';
    };

    systemd.services.reactive-resume = {
      description = "Reactive Resume (docker compose)";
      after = [ "docker.service" "reactive-resume-setup.service" "network-online.target" ];
      requires = [ "docker.service" "reactive-resume-setup.service" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        WorkingDirectory = "/var/lib/reactive-resume";
        ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d --remove-orphans";
        ExecStop = "${pkgs.docker-compose}/bin/docker-compose down";
      };
    };
  };
}
