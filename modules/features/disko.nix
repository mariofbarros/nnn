{ inputs, ... }: {
  # Declarative disk layout, for the *next* fresh install (a wiped nixbook,
  # or a third host) -- not imported by nix-btw/nixbook's configuration.nix,
  # since both are already partitioned by hand and this module reformats
  # whatever device it's pointed at. See docs/new-machine.md for how to use
  # it. Swap the layout below for your target's actual boot mode/disk size
  # before running `disko`.
  flake.nixosModules.diskoExtBoot = { ... }: {
    imports = [ inputs.disko.nixosModules.disko ];

    disko.devices = {
      disk.main = {
        device = "/dev/disk/by-id/CHANGE_ME";
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
                mountOptions = [ "umask=0077" ];
              };
            };
            swap = {
              size = "16G";
              content = {
                type = "swap";
                discardPolicy = "both";
              };
            };
            root = {
              size = "100%";
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
}
