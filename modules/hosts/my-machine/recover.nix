{ self, inputs, ... }: {
  perSystem = { pkgs, lib, ... }: {
    # Run from a booted NixOS live ISO on replacement hardware:
    #   sudo nix run 'github:mariofbarros/nnn#recover'
    # Lists candidate disks, requires typing the chosen path back exactly
    # (no bare y/n) before handing off to disko-install, since a wrong
    # pick here erases a disk.
    packages.recover = pkgs.writeShellApplication {
      name = "recover";
      runtimeInputs = [ pkgs.util-linux ];
      text = ''
        FLAKE_REF="github:mariofbarros/nnn#nix-btw"
        DISKO_APP="github:nix-community/disko/latest#disko-install"

        if [ "$(id -u)" -ne 0 ]; then
          echo "This wipes a disk and installs NixOS -- run it with sudo." >&2
          exit 1
        fi

        echo "== Candidate disks (by-id) =="
        echo

        mapfile -t candidates < <(
          find /dev/disk/by-id -maxdepth 1 \
            \( -name 'nvme-*' -o -name 'ata-*' -o -name 'scsi-*' \) \
            ! -name '*-part*' ! -name '*eui*' \
            | sort
        )

        if [ "''${#candidates[@]}" -eq 0 ]; then
          echo "No candidate disks found under /dev/disk/by-id. Aborting." >&2
          exit 1
        fi

        i=1
        for path in "''${candidates[@]}"; do
          target=$(readlink -f "$path")
          info=$(lsblk -dno SIZE,MODEL,TRAN,RM "$target" 2>/dev/null || echo "?")
          echo "  [$i] $path"
          echo "        -> $target  ($info)"
          echo
          i=$((i + 1))
        done

        read -rp "Select disk number to WIPE and install onto: " choice
        if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "''${#candidates[@]}" ]; then
          echo "Invalid selection." >&2
          exit 1
        fi

        disk="''${candidates[$((choice - 1))]}"

        echo
        echo "About to ERASE ALL DATA on:"
        echo "  $disk"
        echo "  -> $(readlink -f "$disk")"
        echo
        read -rp "Type the disk path above exactly to confirm: " confirm

        if [ "$confirm" != "$disk" ]; then
          echo "Confirmation did not match. Aborting, nothing was touched." >&2
          exit 1
        fi

        echo
        echo "Partitioning and installing NixOS from $FLAKE_REF onto $disk..."
        nix run "$DISKO_APP" -- --write-efi-boot-entries --flake "$FLAKE_REF" --disk main "$disk"

        echo
        echo "Install finished. Remove the install media and reboot:"
        echo "  reboot"
        echo
        echo "After first boot, recreate the SearXNG secret -- see README's Disaster recovery section."
      '';
    };
  };
}
