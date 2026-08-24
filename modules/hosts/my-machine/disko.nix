{ self, inputs, ... }: {
  flake.nixosModules.diskoConfig = { ... }: {
    imports = [ inputs.disko.nixosModules.disko ];

    disko.devices = {
      disk = {
        main = {
          # Only a fallback default for `nixos-rebuild switch` on THIS
          # machine. On real recovery, disko-install's `--disk main <path>`
          # CLI flag overrides this for the whole build, not just
          # partitioning -- so this doesn't need to match future hardware.
          device = "/dev/disk/by-id/nvme-KINGSTON_SNV3S1000G_50026B7785B19BD9";
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "fmask=0077" "dmask=0077" ];
                };
              };
              swap = {
                size = "34G";
                content = { type = "swap"; };
              };
              root = {
                size = "100%"; # must stay last so it takes the remainder
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };
  };
}
