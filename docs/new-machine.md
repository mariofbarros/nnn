# Bootstrapping a new host

Steps for adding a third machine (or reinstalling nixbook from scratch),
using nix-btw/nixbook as the template.

## 1. Partition

For a from-scratch install, use `modules/features/disko.nix`
(`flake.nixosModules.diskoExtBoot`) instead of hand-partitioning: copy it,
point `disko.devices.disk.main.device` at the real `/dev/disk/by-id/...`,
and run it from the installer media:

```console
nix run github:nix-community/disko -- --mode disko ./disko-config.nix
```

This module is **not** imported by nix-btw or nixbook's `configuration.nix`
— both are already partitioned, and importing it would try to reformat
their disks. Only wire it into a host's config for a genuinely fresh
install.

If hand-partitioning instead, get `hardware.nix` the usual way:
`nixos-generate-config` on the target, then copy the generated
`hardware-configuration.nix` content into `modules/hosts/<name>/hardware.nix`
(see `modules/hosts/my-machine/hardware.nix` for the
`flake.nixosModules.<name>Hardware` wrapper shape).

## 2. Create the host directory

`modules/hosts/<name>/` needs, mirroring `modules/hosts/nixbook/`:

- `hardware.nix` — `flake.nixosModules.<name>Hardware`
- `home.nix` — wires home-manager as a NixOS module (see existing hosts)
- `configuration.nix` — `flake.nixosModules.<name>Configuration`, the
  `imports` list of `self.nixosModules.*` features, `networking.hostName`,
  users, `system.stateVersion`
- `default.nix` — the actual `nixosConfigurations.<name>` flake output

Copy an existing host's four files as the starting point and adjust.

## 3. First boot, no secrets yet

`self.nixosModules.secrets` (agenix) can be imported from the start — it
only enables `services.openssh` to generate the host's SSH host key, it
doesn't require any secret to exist yet. Deploy once:

```console
sudo nixos-rebuild switch --flake .#<name>
```

## 4. Register the host as a secrets recipient

Once booted, grab its host key and follow ["Adding a new host as a
recipient"](./secrets.md#adding-a-new-host-as-a-recipient) in
`docs/secrets.md`.

## 5. Everything else

Add `<name>` to the CI matrix in `.github/workflows/ci.yml` so pushes get
build-checked for it too.
