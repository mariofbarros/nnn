let
  # Host identities are each host's own SSH host key (modules/features/
  # secrets.nix sets age.identityPaths to /etc/ssh/ssh_host_ed25519_key,
  # generated the first time sshd starts). mario is added to every secret
  # too so `agenix -e`/`age -d` work directly from this account, not just
  # at activation time on the target host.
  nixBtw = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILI3DZ8EsHZ2WBIgIYvTmDPsCx5FaOZym4LNEbPb5r8Q root@nix-btw";
  nixbook = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMw1SGM7v8Pz7EYRF82d5L4SLNmqUfozPWp5cnwdYLSt root@nixbook";
  mario = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIbtP3jOc+3FufWmuhPL3gMM0KQ8g1Jelm/bzORm7RRL mariofbarros.fsma@gmail.com";
in {
  "searxng-secret.env.age".publicKeys = [ nixBtw nixbook mario ];
}
