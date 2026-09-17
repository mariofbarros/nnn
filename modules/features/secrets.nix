{ self, inputs, ... }: {
  flake.nixosModules.secrets = { ... }: {
    imports = [ inputs.agenix.nixosModules.default ];

    # agenix needs a per-host identity to decrypt secrets at activation.
    # Reusing the SSH host key means no separate key to generate, sync or
    # back up -- sshd is enabled here solely to produce that key, not for
    # remote login, so the firewall stays closed. Flip openFirewall on
    # (per host, in its configuration.nix) if real SSH access is wanted.
    services.openssh = {
      enable = true;
      openFirewall = false;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };
}
