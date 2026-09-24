# Secrets

Secrets are managed with [agenix](https://github.com/ryantm/agenix), wired
up in `modules/features/secrets.nix` and `secrets/secrets.nix`.

## How decryption works here

Each host decrypts using its own SSH host key
(`/etc/ssh/ssh_host_ed25519_key`) as its agenix identity — see
`age.identityPaths` in `modules/features/secrets.nix`. `services.openssh` is
enabled there *only* to generate that key; the firewall stays closed unless
a host's `configuration.nix` explicitly flips `openFirewall` on (nix-btw
does, to accept LAN connections from nixbook).

This means a brand-new host has no usable identity until it boots once —
see the bootstrap order in [new-machine.md](./new-machine.md).

## `secrets/secrets.nix`

The recipient manifest. Each host's SSH host public key (`ssh-ed25519 ...
root@<hostname>`) plus mario's personal key are listed as recipients for
every secret, so `agenix -e` also works directly from mario's account, not
just at activation time on the target host:

```nix
let
  nixBtw = "ssh-ed25519 AAAA... root@nix-btw";
  nixbook = "ssh-ed25519 AAAA... root@nixbook";
  mario = "ssh-ed25519 AAAA... mariofbarros.fsma@gmail.com";
in {
  "some-secret.age".publicKeys = [ nixBtw nixbook mario ];
}
```

## Adding a new secret

From the repo root:

```console
cd secrets
agenix -e new-secret-name.age
```

This opens `$EDITOR` on the decrypted plaintext (nothing is written to disk
unencrypted). Add the entry to `secrets/secrets.nix` first so agenix knows
who the recipients are.

Reference it from a NixOS module the same way `searxng.nix` does:

```nix
age.secrets.new-secret-name.file = ../../../secrets/new-secret-name.age;
# then, e.g.:
environmentFile = config.age.secrets.new-secret-name.path;
```

## Adding a new host as a recipient

1. Get the new host's SSH host public key —
   `cat /etc/ssh/ssh_host_ed25519_key.pub` (requires the host to have booted
   at least once with `modules/features/secrets.nix` imported).
2. Add it as a named binding in `secrets/secrets.nix` and include it in
   every secret's `publicKeys` list that host needs.
3. Rekey so the new host can actually decrypt (from the repo root):
   ```console
   cd secrets && agenix -r
   ```
4. Redeploy the new host.

## Rotating a secret

`agenix -e <file>.age` re-encrypts on save to the current recipient list in
`secrets/secrets.nix` — no separate rotate step needed. If only the
recipient list changed (e.g. after step 2 above), `agenix -r` re-encrypts
every secret without changing plaintext.
