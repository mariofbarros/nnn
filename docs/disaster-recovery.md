# Disaster recovery

> [!WARNING]
> This wipes the target disk. Follow these steps at your own risk — I am
> not responsible for data loss or damage to your (or anyone else's)
> machine if you attempt this. Double-check the disk path before
> confirming anything below.

If the SSD dies, a fresh machine can be brought up from this repo with a
single command, using [disko](https://github.com/nix-community/disko) +
`disko-install`, after booting a NixOS minimal/graphical ISO on the new
hardware. The partition layout is declared in
`modules/hosts/my-machine/disko.nix`.

1. **Boot the NixOS installer ISO** on the new hardware; only `nix` +
   network are required.

2. **Get online.** Ethernet works out of the box; for Wi-Fi use `nmtui`
   or `nmcli device wifi connect <SSID> --ask`.

3. **Run the recovery script — the single command:**
   ```
   sudo nix run 'github:mariofbarros/nnn#recover'
   ```
   It lists candidate disks under `/dev/disk/by-id/` (never the unstable
   `/dev/sdX`/`/dev/nvme0n1` names), makes you pick one, and requires
   typing the chosen path back exactly before doing anything — a wrong
   pick here erases a disk, so there's no bare y/n. Once confirmed, it
   runs `disko-install` for you: partitions and formats per `disko.nix`
   (GPT: 1G vfat `/boot`, 34G swap, ext4 `/` on the remainder), installs
   NixOS from the flake, and registers an EFI boot entry. Source:
   `modules/hosts/my-machine/recover.nix`.

   Equivalent by hand, if you'd rather skip the script and pass the disk
   directly:
   ```
   sudo nix run 'github:nix-community/disko/latest#disko-install' -- \
     --write-efi-boot-entries \
     --flake 'github:mariofbarros/nnn#nix-btw' \
     --disk main /dev/disk/by-id/<disk-id>
   ```

4. **Reboot** and remove the install media:
   ```
   sudo reboot
   ```

5. **Recreate the SearXNG secret file.** It's intentionally not tracked
   in the repo (see `modules/features/searxng/searxng.nix`), so it must
   be regenerated once after every fresh install:
   ```
   sudo install -d -o searx -g searx -m 700 /var/lib/searxng
   echo "SEARX_SECRET_KEY=$(openssl rand -hex 32)" | sudo tee /var/lib/searxng/secret.env
   sudo chown searx:searx /var/lib/searxng/secret.env
   sudo chmod 600 /var/lib/searxng/secret.env
   sudo systemctl restart searx
   ```
   Note: `environmentFile` only feeds systemd's `EnvironmentFile=` for the
   unit — it doesn't wire itself into SearXNG's `secret_key` unless
   `services.searx.settings.server.secret_key` is also set to
   `"$SEARX_SECRET_KEY"`, which this repo doesn't currently do. Low
   priority given SearXNG is bound to `127.0.0.1` only, but worth fixing
   in `searxng.nix` separately.

6. **Log in as `mario`.** home-manager state rebuilds from the same
   flake on first activation.

If `disko-install` ever breaks on a future nixpkgs release, the fallback
is the traditional manual path: partition by hand, `nixos-generate-config`,
then `nixos-install --flake .#nix-btw`.
