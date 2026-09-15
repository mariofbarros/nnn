{ self, inputs, ... }:{

flake.nixosModules.nixbookHardware = { config, lib, pkgs, modulesPath, ... }:

{

  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/5766ccdd-524f-4db4-818e-f7c6f37a1e77";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B486-9ABB";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/9d7c8c98-f87b-4a61-b593-f00b163f0038"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # This laptop's RTL8821CE wifi (rtw88_8821ce) has an upstream-documented
  # ASPM/power-save (LPS) conflict that hard-freezes the whole machine with
  # no kernel log -- the only recovery is a hard reset. Disabling ASPM for
  # the driver and disabling wifi power-saving are the known mitigations.
  boot.extraModprobeConfig = ''
    options rtw88_pci disable_aspm=1
  '';
  networking.networkmanager.wifi.powersave = false;
};
}
